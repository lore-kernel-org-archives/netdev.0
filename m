From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Ilw] drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 15:10:54 +0200
Message-ID: <1127865420.20131015151054@eikelenboom.it>
References: <9010061839.20131015123940@eikelenboom.it> <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:54014 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758486Ab3JONLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 09:11:01 -0400
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Tuesday, October 15, 2013, 12:52:04 PM, you wrote:

>> 
>> Hi,
>> 
>> I'm having a:
>> 
>> 02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6235 (rev
>> 24)
>> 
>> And i'm running into this warning on boot with a 3.11.2 and 3.12-rc5 kernel.
>> 
>> [   23.904950] ------------[ cut here ]------------
>> [   23.904957] WARNING: CPU: 0 PID: 2531 at
>> drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()

> Can you reproduce easily?
> If yes, please reproduce with debug parameters:
> modprobe iwlwifi debug=0xC0800000

> Also, please enable MAC80211_HT_DEBUG

> Thanks

It happens when starting hostapd:

[    7.101116] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.110722] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.154478] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.157691] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.160812] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.164900] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.165019] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.165139] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.165258] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.165377] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.165495] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.165614] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.165733] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.404295] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    7.415368] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[    7.462417] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 9 on FIFO 7 WrPtr: 0
[    7.466588] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 0 on FIFO 3 WrPtr: 0
[    7.470415] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 1 on FIFO 2 WrPtr: 0
[    7.474144] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 2 on FIFO 1 WrPtr: 0
[    7.477514] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 3 on FIFO 0 WrPtr: 0
[    7.480843] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 4 on FIFO 0 WrPtr: 0
[    7.484148] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 5 on FIFO 4 WrPtr: 0
[    7.487432] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 6 on FIFO 2 WrPtr: 0
[    7.490496] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 7 on FIFO 5 WrPtr: 0
[    7.493534] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 8 on FIFO 4 WrPtr: 0
[    7.496562] iwlwifi 0000:02:00.0: U iwl_trans_pcie_txq_enable Activate queue 10 on FIFO 5 WrPtr: 0
[    7.542143] device wlan0 entered promiscuous mode
[    7.544749] xen_bridge: port 2(wlan0) entered forwarding state
[    7.546915] xen_bridge: port 2(wlan0) entered forwarding state
[    7.548825] cfg80211: Pending regulatory request, waiting for it to be processed...
[    7.552798] ------------[ cut here ]------------
[    7.554821] WARNING: CPU: 1 PID: 2445 at drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x776/0x979()
[    7.554824] Modules linked in: acpi_cpufreq
[    7.554827] CPU: 1 PID: 2445 Comm: hostapd Not tainted 3.12.0-rc5+ #1
[    7.554828] Hardware name:                  /D53427RKE, BIOS RKPPT10H.86A.0017.2013.0425.1251 04/25/2013
[    7.554831]  0000000000000000 0000000000000009 ffffffff818a8082 0000000000000000
[    7.554833]  ffffffff8105a4f2 0000000000000000 ffffffff815f440a ffff8800d6df1c80
[    7.554835]  ffff8800d6cb1790 ffff8800d6df1c80 0000000000000007 0000000000000000
[    7.554835] Call Trace:
[    7.554842]  [<ffffffff818a8082>] ? dump_stack+0x41/0x51
[    7.554845]  [<ffffffff8105a4f2>] ? warn_slowpath_common+0x78/0x90
[    7.554850]  [<ffffffff815f440a>] ? iwlagn_tx_skb+0x776/0x979
[    7.554852]  [<ffffffff815f440a>] ? iwlagn_tx_skb+0x776/0x979
[    7.554855]  [<ffffffff815f2407>] ? iwlagn_mac_tx+0x19/0x30
[    7.554858]  [<ffffffff8187a259>] ? __ieee80211_tx+0x226/0x29b
[    7.554860]  [<ffffffff8187bcd1>] ? ieee80211_tx+0xa6/0xb5
[    7.554865]  [<ffffffff8187bf9f>] ? ieee80211_monitor_start_xmit+0x1e9/0x204
[    7.554867]  [<ffffffff8172e1eb>] ? dev_hard_start_xmit+0x271/0x3ec
[    7.554871]  [<ffffffff81746538>] ? sch_direct_xmit+0x66/0x164
[    7.554873]  [<ffffffff8172e54b>] ? dev_queue_xmit+0x1e5/0x3c8
[    7.554876]  [<ffffffff8180bfe6>] ? packet_sendmsg+0xac5/0xb3d
[    7.554881]  [<ffffffff8171ad95>] ? sock_sendmsg+0x37/0x52
[    7.554884]  [<ffffffff810f9e0c>] ? __do_fault+0x338/0x36b
[    7.554886]  [<ffffffff81724bac>] ? verify_iovec+0x44/0x94
[    7.554889]  [<ffffffff8171b1ef>] ? ___sys_sendmsg+0x1f1/0x283
[    7.554893]  [<ffffffff81140a73>] ? __inode_wait_for_writeback+0x67/0xae
[    7.554895]  [<ffffffff8111735e>] ? __cache_free.isra.46+0x178/0x187
[    7.554897]  [<ffffffff811173b1>] ? kmem_cache_free+0x44/0x84
[    7.554900]  [<ffffffff81132c22>] ? dentry_kill+0x13d/0x149
[    7.554902]  [<ffffffff81132f6f>] ? dput+0xe5/0xef
[    7.554905]  [<ffffffff81136e04>] ? fget_light+0x2e/0x7c
[    7.554908]  [<ffffffff8171c1ee>] ? __sys_sendmsg+0x39/0x57
[    7.554911]  [<ffffffff818b5e39>] ? system_call_fastpath+0x16/0x1b
[    7.554912] ---[ end trace beb2b581b91027a7 ]---
[    7.554917] iwlwifi 0000:02:00.0: I iwlagn_tx_skb TX to [14|8] Q:7 - seq: 0x0
[    7.555036] device wlan0 left promiscuous mode
[    7.555042] xen_bridge: port 2(wlan0) entered disabled state
[    7.557861] iwlwifi 0000:02:00.0: I iwl_trans_pcie_reclaim [Q 7] 0 -> 1 (1)
[    7.557865] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx TXQ 7 status SUCCESS (0x00000201)
[    7.557867] iwlwifi 0000:02:00.0: I iwlagn_rx_reply_tx                               initial_rate 0x820a retries 0, idx=0 ssn=1 seq_ctl=0x0
[    7.626274] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x23
[    7.670694] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x24
[    7.673864] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x25
[    7.677083] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x26
[    7.681410] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x27
[    7.684761] iwlwifi 0000:02:00.0: I iwl_pcie_txq_inc_wr_ptr Q:9 WR: 0x28
[    7.686906] iwlwifi 0000:02:00.0: I iwl_pcie_txq_unmap Q 9 Free 39
