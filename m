From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: one more WARNING
Date: Wed, 19 Mar 2008 18:47:21 +0200
Message-ID: <20080319164707.M62133@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:57989 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765942AbYCSUSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:18:09 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 557B0BDB8F
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 18:47:21 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ 9178.311398] ------------[ cut here ]------------
[ 9178.311407] WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11e/
0x126()
[ 9178.311410] Modules linked in: tcp_lp xt_dscp xt_owner xt_tcpudp mptspi 
mptsas scsi_transport_spi scsi_transport_sas mptscsih mptbase xfs em_nbyte 
cls_tcindex act_gact cls_rsvp sch_htb cls_fw act_mirred em_u32 sch_red 
sch_sfq sch_tbf sch_teql cls_basic act_police sch_gred act_pedit sch_hfsc 
cls_rsvp6 sch_ingress em_meta em_text act_ipt sch_dsmark sch_prio sch_netem 
act_simple cls_u32 em_cmp sch_cbq cls_route xt_TCPMSS iptable_nat 
nf_conntrack_ipv4 ipt_LOG ipt_MASQUERADE ipt_REDIRECT nf_nat nf_conntrack 
nfnetlink iptable_filter ip_tables x_tables 8021q tun tulip r8169 sky2 
via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 8139too e1000 e100 
usb_storage mtdblock mtd_blkdevs usbhid uhci_hcd ehci_hcd ohci_hcd usbcore
[ 9178.311462] Pid: 1568, comm: globax Not tainted 2.6.25-rc6-git2-build-0024 
#8
[ 9178.311475]  [<c0121048>] warn_on_slowpath+0x41/0x51
[ 9178.311519]  [<c013bdc3>] ? mark_held_locks+0x41/0x5c
[ 9178.311529]  [<c012575a>] ? local_bh_enable_ip+0xb0/0xb6
[ 9178.311539]  [<c013bf40>] ? trace_hardirqs_on+0xd3/0x111
[ 9178.311546]  [<f89f2984>] ? __nf_ct_refresh_acct+0xd3/0x10b [nf_conntrack]
[ 9178.311570]  [<c02beb1c>] ? _spin_unlock_bh+0x25/0x28
[ 9178.311582]  [<f89f2984>] ? __nf_ct_refresh_acct+0xd3/0x10b [nf_conntrack]
[ 9178.311607]  [<f89f60c6>] ? tcp_packet+0x9a7/0x9e5 [nf_conntrack]
[ 9178.311637]  [<c013ce1f>] ? __lock_acquire+0xaef/0xb37
[ 9178.311670]  [<c02931d7>] tcp_mark_head_lost+0x11e/0x126
[ 9178.311686]  [<c02956ac>] tcp_ack+0x1535/0x17c3
[ 9178.311764]  [<c0297f53>] tcp_rcv_established+0xce/0x7df
[ 9178.311789]  [<c029d136>] tcp_v4_do_rcv+0x28/0x181
[ 9178.311811]  [<c029ec34>] tcp_v4_rcv+0x663/0x6af
[ 9178.311839]  [<c0287544>] ip_local_deliver_finish+0xdc/0x15f
[ 9178.311851]  [<c0287929>] ip_local_deliver+0x64/0x6f
[ 9178.311860]  [<c028742e>] ip_rcv_finish+0x2ba/0x2f4
[ 9178.311878]  [<c028789b>] ip_rcv+0x202/0x22c
[ 9178.311893]  [<c026c809>] netif_receive_skb+0x38d/0x3ec
[ 9178.311921]  [<f890642b>] e1000_clean_rx_irq+0x369/0x42f [e1000]
[ 9178.311990]  [<f8903db6>] e1000_clean+0x62/0x1fd [e1000]
[ 9178.312019]  [<c026e977>] net_rx_action+0xb3/0x1d8
[ 9178.312038]  [<c0125846>] __do_softirq+0x6f/0xe9
[ 9178.312052]  [<c01060ab>] do_softirq+0x5e/0xa8
[ 9178.312062]  [<c0146413>] ? handle_fasteoi_irq+0x0/0xb6
[ 9178.312069]  [<c01257a4>] irq_exit+0x44/0x77
[ 9178.312075]  [<c01061af>] do_IRQ+0xba/0xd3
[ 9178.312088]  [<c010438e>] common_interrupt+0x2e/0x34
[ 9178.312128]  =======================
[ 9178.312131] ---[ end trace 1d98aa796f2bac59 ]---


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

