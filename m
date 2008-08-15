From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: 2.6.27-rc3-git2
Date: Fri, 15 Aug 2008 19:24:07 +0300
Message-ID: <200808151924.09132.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51151 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbYHOQZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 12:25:17 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 8522A1303F0
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 19:25:14 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just i notice warning while checking syslog.
Posting here, if it's matter.

Aug 15 13:17:36  [11769.573462] ------------[ cut here ]------------
Aug 15 13:17:36  [11769.573462] WARNING: at kernel/softirq.c:136 local_bh_enable_ip+0x35/0xaa()
Aug 15 13:17:36  [11769.573462] Modules linked in: coretemp hwmon i2c_i801 i2c_core nf_nat_ftp nf_conntrack_ftp softdog nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_pr
oto_gre netconsole configfs hangcheck_timer act_mirred sch_ing
Aug 15 13:17:36  [11769.573462] Pid: 2395, comm: sh Not tainted 2.6.27-rc3-git2-build-0030 #9
Aug 15 13:17:36  [11769.573462]  [<c02ba45b>] ? printk+0xf/0x14
Aug 15 13:17:36  [11769.573462]  [<c0121be8>] warn_on_slowpath+0x41/0x65
Aug 15 13:17:36  [11769.573462]  [<c013c7d8>] ? trace_hardirqs_off+0xb/0xd
Aug 15 13:17:36  [11769.573462]  [<c013c7d8>] ? trace_hardirqs_off+0xb/0xd
Aug 15 13:17:36  [11769.573462]  [<c013c7d8>] ? trace_hardirqs_off+0xb/0xd
Aug 15 13:17:36  [11769.573462]  [<c016540f>] ? kmem_cache_free+0x91/0xa4
Aug 15 13:17:36  [11769.573462]  [<c025bfc4>] ? __kfree_skb+0x63/0x66
Aug 15 13:17:36  [11769.573462]  [<c013c7d8>] ? trace_hardirqs_off+0xb/0xd
Aug 15 13:17:36  [11769.573462]  [<c01647d6>] ? __kmalloc_track_caller+0x98/0xd2
Aug 15 13:17:36  [11769.573462]  [<c025d16a>] ? __netdev_alloc_skb+0x17/0x35
Aug 15 13:17:36  [11769.573462]  [<f89ea2b8>] ? destroy_conntrack+0xcd/0xf1 [nf_conntrack]
Aug 15 13:17:36  [11769.573462]  [<c0125fdc>] local_bh_enable_ip+0x35/0xaa
Aug 15 13:17:36  [11769.573462]  [<c02bc800>] _spin_unlock_bh+0x25/0x28
Aug 15 13:17:36  [11769.573462]  [<f89ea2b8>] destroy_conntrack+0xcd/0xf1 [nf_conntrack]
Aug 15 13:17:36  [11769.573462]  [<c027680a>] nf_conntrack_destroy+0x34/0x4d
Aug 15 13:17:36  [11769.573462]  [<c025c7fa>] skb_release_all+0x50/0x8d
Aug 15 13:17:36  [11769.573462]  [<c025bf6c>] __kfree_skb+0xb/0x66
Aug 15 13:17:36  [11769.573462]  [<c026c173>] zap_completion_queue+0x66/0x71
Aug 15 13:17:36  [11769.573462]  [<c026c49b>] netpoll_poll+0x31d/0x336
Aug 15 13:17:36  [11769.573462]  [<c01647d6>] ? __kmalloc_track_caller+0x98/0xd2
Aug 15 13:17:36  [11769.573462]  [<c026c4e0>] ? find_skb+0x2c/0x6d
Aug 15 13:17:36  [11769.573462]  [<c026c5dd>] netpoll_send_skb+0xbc/0x159
Aug 15 13:17:36  [11769.573462]  [<c026c84b>] netpoll_send_udp+0x1d1/0x1da
Aug 15 13:17:36  [11769.573462]  [<f8a64146>] write_msg+0x7f/0xb9 [netconsole]
Aug 15 13:17:36  [11769.573462]  [<f8a640c7>] ? write_msg+0x0/0xb9 [netconsole]
Aug 15 13:17:36  [11769.573462]  [<c0121e6f>] __call_console_drivers+0x56/0x63
Aug 15 13:17:36  [11769.573462]  [<c0121ed3>] _call_console_drivers+0x57/0x5b
Aug 15 13:17:36  [11769.573462]  [<c012223b>] release_console_sem+0x113/0x1aa
Aug 15 13:17:36  [11769.573462]  [<c012271d>] vprintk+0x2b5/0x2e1
Aug 15 13:17:36  [11769.573462]  [<c02ba45b>] printk+0xf/0x14
Aug 15 13:17:36  [11769.573462]  [<f89e6092>] softdog_release+0x2c/0x63 [softdog]
Aug 15 13:17:36  [11769.573462]  [<c0167db8>] __fput+0x99/0x136
Aug 15 13:17:36  [11769.573462]  [<c0167e6c>] fput+0x17/0x19
Aug 15 13:17:36  [11769.573462]  [<c016593b>] filp_close+0x47/0x51
Aug 15 13:17:36  [11769.573462]  [<c01659b8>] sys_close+0x73/0xad
Aug 15 13:17:36  [11769.573462]  [<c0103861>] sysenter_do_call+0x12/0x35
Aug 15 13:17:36  [11769.573462]  [<c02b007b>] ? enable_nonboot_cpus+0xf/0x8d
Aug 15 13:17:36  [11769.573462]  =======================
