From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: WARNING: at net/core/dev.c:1904 skb_gso_segment+0x146/0x298()
Date: Thu, 24 Nov 2011 01:30:34 +0100
Message-ID: <4ECD902A.8080206@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:45363 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005Ab1KXAa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 19:30:56 -0500
Received: from unknown (HELO [192.168.1.200]) (itcare_pstaszewski@[82.160.6.137])
          (envelope-sender <pstaszewski@itcare.pl>)
          by iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 24 Nov 2011 00:30:40 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

After upgrade from 2.6.38.2 to 3.1.2 i have this im dmesg:
[  600.266497] WARNING: at net/core/dev.c:1904 skb_gso_segment+0x146/0x298()
[  600.266500] Hardware name: X8DTU-6+
[  600.266503] 802.1Q VLAN Support: caps=(0x20115833, 0x0) len=2816 
data_len=2776 ip_summed=1
[  600.266506] Modules linked in: macvlan
[  600.266511] Pid: 0, comm: kworker/0:1 Not tainted 3.1.2 #1
[  600.266513] Call Trace:
[  600.266515] <IRQ>  [<ffffffff8103449c>] warn_slowpath_common+0x80/0x98
[  600.266527]  [<ffffffff81034548>] warn_slowpath_fmt+0x41/0x43
[  600.266530]  [<ffffffff813c838f>] skb_gso_segment+0x146/0x298
[  600.266535]  [<ffffffff8103994e>] ? local_bh_enable+0xd/0xf
[  600.266540]  [<ffffffff813cc646>] dev_hard_start_xmit+0x35a/0x57d
[  600.266544]  [<ffffffff8103994e>] ? local_bh_enable+0xd/0xf
[  600.266548]  [<ffffffff813cccb2>] dev_queue_xmit+0x449/0x4ef
[  600.266554]  [<ffffffff813ffc4d>] ip_finish_output2+0x1c4/0x201
[  600.266560]  [<ffffffff813ffd1c>] ip_finish_output+0x92/0x97
[  600.266562]  [<ffffffff813ffe7c>] T.1037+0x4f/0x56
[  600.266565]  [<ffffffff81400005>] ip_output+0x58/0x5b
[  600.266567]  [<ffffffff813fc4f0>] ip_forward_finish+0x44/0x48
[  600.266569]  [<ffffffff813fc7f4>] ip_forward+0x300/0x36c
[  600.266572]  [<ffffffff813fb144>] ip_rcv_finish+0x2a4/0x2ce
[  600.266575]  [<ffffffff813faea0>] ? inet_del_protocol+0x37/0x37
[  600.266577]  [<ffffffff813fb431>] T.935+0x4c/0x53
[  600.266579]  [<ffffffff813fb6bc>] ip_rcv+0x237/0x263
[  600.266582]  [<ffffffff813cb76b>] __netif_receive_skb+0x41d/0x44f
[  600.266584]  [<ffffffff813cb891>] process_backlog+0xf4/0x1d3
[  600.266587]  [<ffffffff813cbfee>] net_rx_action+0x74/0x1cb
[  600.266589]  [<ffffffff81039a74>] __do_softirq+0xc8/0x1a4
[  600.266591]  [<ffffffff81039b31>] ? __do_softirq+0x185/0x1a4
[  600.266595]  [<ffffffff814a8bec>] call_softirq+0x1c/0x30
[  600.266599]  [<ffffffff8100385d>] do_softirq+0x41/0x7e
[  600.266601]  [<ffffffff8103987b>] irq_exit+0x44/0x74
[  600.266603]  [<ffffffff81003182>] do_IRQ+0x98/0xaf
[  600.266606]  [<ffffffff814a0f2e>] common_interrupt+0x6e/0x6e
[  600.266608] <EOI>  [<ffffffff8100887e>] ? mwait_idle+0x7e/0xa4
[  600.266613]  [<ffffffff81008836>] ? mwait_idle+0x36/0xa4
[  600.266615]  [<ffffffff81001da7>] cpu_idle+0x5f/0x91
[  600.266620]  [<ffffffff81acca55>] start_secondary+0x192/0x196
[  600.266622] ---[ end trace 15512840060b2da9 ]---

Network controller: Intel Corporation 82598EB 10-Gigabit AT CX4 Network 
Connection (rev 01)
ethtool -i eth4
driver: ixgbe
version: 3.4.8-k
firmware-version: 1.12-2
bus-info: 0000:04:00.0

ethtool -k eth4
Offload parameters for eth4:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: on


Thanks
Pawel
