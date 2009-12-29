From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 14953] New: WARNING: at
 /build/buildd/linux-2.6.31/net/ipv4/tcp_input.c:2920
Date: Tue, 29 Dec 2009 09:27:36 -0800
Message-ID: <20091229092736.583b9f37@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33848 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbZL2R1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2009 12:27:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 29 Dec 2009 16:55:10 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 14953] New: WARNING: at /build/buildd/linux-2.6.31/net/ipv4/tcp_input.c:2920


http://bugzilla.kernel.org/show_bug.cgi?id=14953

           Summary: WARNING: at
                    /build/buildd/linux-2.6.31/net/ipv4/tcp_input.c:2920
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.31.x
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: pl4nkton@googlemail.com
        Regression: No


[77796.067111] WARNING: at /build/buildd/linux-2.6.31/net/ipv4/tcp_input.c:2920
tcp_fastretrans_alert+0x461/0xc20()
[77796.067119] Hardware name: System Product Name
[77796.067123] Modules linked in: bridge 8021q garp stp snd_hda_codec_atihdmi
snd_hda_codec_realtek snd_hda_intel snd_hda_codec radeon ttm snd_hwdep drm
snd_pcm snd_timer i2c_algo_bit ixgbe snd shpchp soundcore iptable_filter
psmouse dca i2c_piix4 snd_page_alloc ip_tables amd64_edac_mod serio_raw
edac_core x_tables mdio asus_atk0110 usbhid sky2 3w_9xxx
[77796.067183] Pid: 7217, comm: proftpd Not tainted 2.6.31-16-server #53-Ubuntu
[77796.067188] Call Trace:
[77796.067193]  <IRQ>  [<ffffffff8105e618>] warn_slowpath_common+0x78/0xb0
[77796.067214]  [<ffffffff8105e65f>] warn_slowpath_null+0xf/0x20
[77796.067222]  [<ffffffff81479281>] tcp_fastretrans_alert+0x461/0xc20
[77796.067230]  [<ffffffff8147a4d4>] tcp_ack+0x284/0x6a0
[77796.067237]  [<ffffffff81477fc6>] ? tcp_validate_incoming+0x96/0x330
[77796.067245]  [<ffffffff8147b220>] tcp_rcv_established+0x400/0x690
[77796.067254]  [<ffffffff814834bb>] tcp_v4_do_rcv+0xeb/0x150
[77796.067262]  [<ffffffff81484aa5>] tcp_v4_rcv+0x5d5/0x830
[77796.067270]  [<ffffffff814624e0>] ? ip_local_deliver_finish+0x0/0x2d0
[77796.067280]  [<ffffffff8145a606>] ? nf_hook_slow+0xa6/0x100
[77796.067288]  [<ffffffff814624e0>] ? ip_local_deliver_finish+0x0/0x2d0
[77796.067296]  [<ffffffff814625b5>] ip_local_deliver_finish+0xd5/0x2d0
[77796.067304]  [<ffffffff81462838>] ip_local_deliver+0x88/0xa0
[77796.067311]  [<ffffffff81462035>] ip_rcv_finish+0x115/0x460
[77796.067318]  [<ffffffff81462ac4>] ip_rcv+0x274/0x350
[77796.067327]  [<ffffffff8143833a>] netif_receive_skb+0x38a/0x5d0
[77796.067335]  [<ffffffff814387be>] napi_gro_complete+0x7e/0xd0
[77796.067342]  [<ffffffff81438c57>] napi_gro_flush+0x27/0x50
[77796.067349]  [<ffffffff81438c9f>] napi_complete+0x1f/0x50
[77796.067373]  [<ffffffffa00ddac8>] ixgbe_clean_rxonly+0x98/0x130 [ixgbe]
[77796.067382]  [<ffffffff81438dd7>] net_rx_action+0x107/0x250
[77796.067391]  [<ffffffff810651fd>] __do_softirq+0xbd/0x200
[77796.067399]  [<ffffffff81014bdd>] ? handle_irq+0x1d/0x30
[77796.067420]  [<ffffffff810131ac>] call_softirq+0x1c/0x30
[77796.067424]  <EOI>  [<ffffffff81014b85>] do_softirq+0x55/0x90
[77796.067436]  [<ffffffff81065d90>] local_bh_enable_ip+0xa0/0xb0
[77796.067446]  [<ffffffff81527364>] _spin_unlock_bh+0x14/0x20
[77796.067453]  [<ffffffff8142780a>] release_sock+0xba/0xd0
[77796.067460]  [<ffffffff81470038>] tcp_sendpage+0x68/0x80
[77796.067470]  [<ffffffff81423746>] kernel_sendpage+0x16/0x30
[77796.067478]  [<ffffffff81423796>] sock_sendpage+0x36/0x40
[77796.067487]  [<ffffffff81140241>] pipe_to_sendpage+0x61/0x80
[77796.067495]  [<ffffffff811402ca>] splice_from_pipe_feed+0x6a/0x120
[77796.067502]  [<ffffffff811401e0>] ? pipe_to_sendpage+0x0/0x80
[77796.067510]  [<ffffffff811401e0>] ? pipe_to_sendpage+0x0/0x80
[77796.067517]  [<ffffffff811408de>] __splice_from_pipe+0x6e/0x80
[77796.067525]  [<ffffffff811401e0>] ? pipe_to_sendpage+0x0/0x80
[77796.067532]  [<ffffffff81140b3c>] splice_from_pipe+0x4c/0x70
[77796.067540]  [<ffffffff81140ba0>] generic_splice_sendpage+0x10/0x20
[77796.067548]  [<ffffffff8114147d>] do_splice_from+0x6d/0xa0
[77796.067556]  [<ffffffff8114174b>] direct_splice_actor+0x1b/0x20
[77796.067563]  [<ffffffff811412be>] splice_direct_to_actor+0xce/0x1c0
[77796.067571]  [<ffffffff81141730>] ? direct_splice_actor+0x0/0x20
[77796.067579]  [<ffffffff811413f8>] do_splice_direct+0x48/0x60
[77796.067589]  [<ffffffff8111f0e1>] do_sendfile+0x1a1/0x240
[77796.067598]  [<ffffffff8111f201>] sys_sendfile64+0x81/0xa0
[77796.067607]  [<ffffffff81011fc2>] system_call_fastpath+0x16/0x1b
[77796.067613] ---[ end trace 876820b0d94f728a ]---

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
