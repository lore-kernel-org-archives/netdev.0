From: Chris Bainbridge <chris.bainbridge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: UBSAN: Undefined behaviour in net/mac80211/rx.c:924:18
Date: Tue, 26 Jan 2016 11:17:30 +0000
Message-ID: <20160126111730.GA6765@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

4.5.0-rc1 another UBSAN error:

[ 4845.229441] ================================================================================
[ 4845.229454] UBSAN: Undefined behaviour in net/mac80211/rx.c:924:18
[ 4845.229458] load of value 2 is not a valid value for type '_Bool'
[ 4845.229464] CPU: 1 PID: 6266 Comm: kworker/u16:8 Not tainted 4.5.0-rc1 #252
[ 4845.229468] Hardware name: Apple Inc. MacBookPro10,2/Mac-AFD8A9D944EA4843, BIOS MBP102.88Z.0106.B0A.1509130955 09/13/2015
[ 4845.229491] Workqueue: phy2 rt2x00usb_work_rxdone
[ 4845.229493]  0000000000000000 0000000000000000 0000000000000002 ffff8801b13c39f8
[ 4845.229496]  ffffffff81b2e7d9 0000000000000007 ffff8801b13c3a20 ffff8801b13c3a10
[ 4845.229498]  ffffffff81bcb87d ffffffff85016890 ffff8801b13c3a60 ffffffff81bcc279
[ 4845.229501] Call Trace:
[ 4845.229506]  [<ffffffff81b2e7d9>] dump_stack+0x45/0x6c
[ 4845.229510]  [<ffffffff81bcb87d>] ubsan_epilogue+0xd/0x40
[ 4845.229513]  [<ffffffff81bcc279>] __ubsan_handle_load_invalid_value+0x69/0x80
[ 4845.229517]  [<ffffffff82280032>] ? xhci_setup_addressable_virt_dev+0xeb2/0x13b0
[ 4845.229520]  [<ffffffff8121230b>] ? pick_next_entity+0xcb/0x280
[ 4845.229524]  [<ffffffff82a7bce3>] ieee80211_sta_reorder_release.isra.15+0x7e3/0xad0
[ 4845.229527]  [<ffffffff82a86837>] ieee80211_prepare_and_rx_handle+0x11a7/0x2ab0
[ 4845.229530]  [<ffffffff82272694>] ? xhci_urb_enqueue+0x394/0x1140
[ 4845.229533]  [<ffffffff82205d8f>] ? usb_hcd_map_urb_for_dma+0x94f/0x1140
[ 4845.229537]  [<ffffffff82552927>] ? skb_release_data+0x117/0x2f0
[ 4845.229539]  [<ffffffff82a883aa>] __ieee80211_rx_handle_packet+0x26a/0x9a0
[ 4845.229542]  [<ffffffff8254ef8c>] ? __kmalloc_reserve.isra.11+0x2c/0x80
[ 4845.229545]  [<ffffffff82a89131>] ieee80211_rx_napi+0x651/0x12b0
[ 4845.229549]  [<ffffffff82188972>] rt2x00lib_rxdone+0x402/0x1120
[ 4845.229552]  [<ffffffff8121b8ff>] ? dequeue_task_fair+0x97f/0x41d0
[ 4845.229554]  [<ffffffff8219d19c>] rt2x00usb_work_rxdone+0xac/0x1f0
[ 4845.229558]  [<ffffffff82b37cbd>] ? __schedule+0x5cd/0x1770
[ 4845.229561]  [<ffffffff811dc3b6>] process_one_work+0x266/0xc00
[ 4845.229563]  [<ffffffff811dce56>] worker_thread+0x96/0xd40
[ 4845.229565]  [<ffffffff811dcdc0>] ? process_scheduled_works+0x70/0x70
[ 4845.229568]  [<ffffffff811e91d8>] kthread+0x108/0x180
[ 4845.229571]  [<ffffffff811e90d0>] ? kthread_create_on_node+0x210/0x210
[ 4845.229573]  [<ffffffff82b40d9f>] ret_from_fork+0x3f/0x70
[ 4845.229576]  [<ffffffff811e90d0>] ? kthread_create_on_node+0x210/0x210
[ 4845.229577] ================================================================================
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
