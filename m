From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 12:39:40 +0200
Message-ID: <9010061839.20131015123940@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilw@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	johannes.berg@intel.com, <ilw@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:52894 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758507Ab3JOKqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 06:46:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having a:

02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6235 (rev 24)

And i'm running into this warning on boot with a 3.11.2 and 3.12-rc5 kernel.

[   23.904950] ------------[ cut here ]------------
[   23.904957] WARNING: CPU: 0 PID: 2531 at drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()
[   23.904959] Modules linked in:
[   23.904962] CPU: 0 PID: 2531 Comm: hostapd Not tainted 3.12.0-rc5+ #1
[   23.904963] Hardware name:                  /D53427RKE, BIOS RKPPT10H.86A.0017.2013.0425.1251 04/25/2013
[   23.904966]  0000000000000000 0000000000000009 ffffffff8189aa62 0000000000000000
[   23.904968]  ffffffff8105a4f2 ffff880058339a48 ffffffff815f8a04 0000000000000000
[   23.904970]  ffff8800560097b0 0000000000000208 0000000000000000 ffff8800561a9e5e
[   23.904971] Call Trace:
[   23.904977]  [<ffffffff8189aa62>] ? dump_stack+0x41/0x51
[   23.904981]  [<ffffffff8105a4f2>] ? warn_slowpath_common+0x78/0x90
[   23.904984]  [<ffffffff815f8a04>] ? iwlagn_tx_skb+0x6c5/0x883
[   23.904986]  [<ffffffff815f8a04>] ? iwlagn_tx_skb+0x6c5/0x883
[   23.904989]  [<ffffffff818a0040>] ? put_cred+0x15/0x15
[   23.904991]  [<ffffffff815f6db4>] ? iwlagn_mac_tx+0x19/0x2f
[   23.904995]  [<ffffffff8186cc45>] ? __ieee80211_tx+0x226/0x29b
[   23.904998]  [<ffffffff8186e6bd>] ? ieee80211_tx+0xa6/0xb5
[   23.905001]  [<ffffffff8186e98b>] ? ieee80211_monitor_start_xmit+0x1e9/0x204
[   23.905005]  [<ffffffff8171ce5f>] ? dev_hard_start_xmit+0x271/0x3ec
[   23.905008]  [<ffffffff817351ac>] ? sch_direct_xmit+0x66/0x164
[   23.905010]  [<ffffffff8171d1bf>] ? dev_queue_xmit+0x1e5/0x3c8
[   23.905013]  [<ffffffff817fac5a>] ? packet_sendmsg+0xac5/0xb3d
[   23.905017]  [<ffffffff81709a09>] ? sock_sendmsg+0x37/0x52
[   23.905020]  [<ffffffff810f9e0c>] ? __do_fault+0x338/0x36b
[   23.905023]  [<ffffffff81713820>] ? verify_iovec+0x44/0x94
[   23.905025]  [<ffffffff81709e63>] ? ___sys_sendmsg+0x1f1/0x283
[   23.905029]  [<ffffffff81140a73>] ? __inode_wait_for_writeback+0x67/0xae
[   23.905031]  [<ffffffff8111735e>] ? __cache_free.isra.46+0x178/0x187
[   23.905033]  [<ffffffff811173b1>] ? kmem_cache_free+0x44/0x84
[   23.905036]  [<ffffffff81132c22>] ? dentry_kill+0x13d/0x149
[   23.905038]  [<ffffffff81132f6f>] ? dput+0xe5/0xef
[   23.905041]  [<ffffffff81136e04>] ? fget_light+0x2e/0x7c
[   23.905043]  [<ffffffff8170ae62>] ? __sys_sendmsg+0x39/0x57
[   23.905046]  [<ffffffff818a7e39>] ? system_call_fastpath+0x16/0x1b
[   23.905047] ---[ end trace 1b3eb79359c1d1e6 ]---

--
Sander
