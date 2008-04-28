From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: WARNING: at net/ipv4/tcp_input.c
Date: Mon, 28 Apr 2008 13:02:39 +0100
Message-ID: <4815BCDF.6070704@andyfurniss.entadsl.com>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:58464 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765452AbYD1MCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 08:02:40 -0400
Received: from localhost (smtp-filter.ukfsn.org [192.168.54.205])
	by mail.ukfsn.org (Postfix) with ESMTP id 999A9DECF6
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 13:05:12 +0100 (BST)
Received: from mail.ukfsn.org ([192.168.54.25])
	by localhost (smtp-filter.ukfsn.org [192.168.54.205]) (amavisd-new, port 10024)
	with ESMTP id dUk25zuySmnf for <netdev@vger.kernel.org>;
	Mon, 28 Apr 2008 12:44:39 +0100 (BST)
Received: from [192.168.0.3] (78-32-18-90.no-dns-yet.enta.net [78.32.18.90])
	by mail.ukfsn.org (Postfix) with ESMTP id 54A29DECE3
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 13:05:12 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since upgrading to 2.6.25 from 2.6.21.1 I've noticed a few of these.

timestamps are off everything else tcp is default.

This is my gateway/torrent/TV server there is nearly always torrent traffic.

I've always had issues with the tulip nic (4 port zynx that doesn't like 
my desktop being off - it's connected with a crossover cable. The ports 
to a switch and modem are always on and OK) I haven't seen these 
warnings on 2.6.21.1.

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0x1dc2/0x1df0()
Modules linked in: saa7134_dvb tda826x mt352 tda10086 dvb_pll tuner 
tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx tea5761 saa7134 
videodev v4l1_compat compat_ioctl32 v4l2_common ir_kbd_i2c ir_common 
tveeprom videobuf_dvb dvb_core videobuf_dma_sg videobuf_core nxt200x 
isl6421 tda1004x firmware_class tda827x cls_flow sch_ingress xt_mark 
xt_length xt_MARK cls_u32 sch_sfq cls_fw sch_htb ipt_REJECT xt_state 
iptable_filter xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle nf_nat_ftp 
nf_conntrack_ftp iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 
nf_conntrack bridge llc container fan thermal processor button tulip
Pid: 0, comm: swapper Not tainted 2.6.25 #1
  [<c011b23f>] warn_on_slowpath+0x5f/0x90
  [<c03191d6>] dev_queue_xmit+0x96/0x280
  [<c033a910>] ip_finish_output+0x0/0x2b0
  [<c033aa4c>] ip_finish_output+0x13c/0x2b0
  [<d4884b58>] __nf_ct_refresh_acct+0xe8/0x160 [nf_conntrack]
  [<d488814a>] tcp_packet+0x48a/0xb70 [nf_conntrack]
  [<c036a52d>] bictcp_cong_avoid+0x1d/0x1f0
  [<c0347fb2>] tcp_ack+0x1dc2/0x1df0
  [<c0349cbe>] tcp_rcv_established+0x3de/0x730
  [<c0350af3>] tcp_v4_do_rcv+0xb3/0x1d0
  [<c032fda0>] nf_iterate+0x60/0x90
  [<c0335cd0>] ip_local_deliver_finish+0x0/0x1a0
  [<c0351239>] tcp_v4_rcv+0x629/0x6f0
  [<c0335d64>] ip_local_deliver_finish+0x94/0x1a0
  [<c0335cd0>] ip_local_deliver_finish+0x0/0x1a0
  [<c0335853>] ip_rcv_finish+0x103/0x320
  [<c0335750>] ip_rcv_finish+0x0/0x320
  [<c0335c0a>] ip_rcv+0x19a/0x260
  [<c0335750>] ip_rcv_finish+0x0/0x320
  [<c0319660>] netif_receive_skb+0x2a0/0x450
  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
  [<d4825ca8>] tulip_interrupt+0x568/0x840 [tulip]
  [<c0134c96>] tick_program_event+0x36/0x70
  [<c0316483>] net_rx_action+0x93/0x150
  [<c011f992>] __do_softirq+0x42/0xa0
  [<c011fa16>] do_softirq+0x26/0x30
  [<c010645a>] do_IRQ+0x4a/0x80
  [<c01344eb>] tick_notify+0x1ab/0x270
  [<c010474f>] common_interrupt+0x23/0x28
  [<d483cd05>] acpi_idle_enter_simple+0x153/0x1c6 [processor]
  [<c02d8fbb>] cpuidle_idle_call+0x6b/0xa0
  [<c02d8f50>] cpuidle_idle_call+0x0/0xa0
  [<c0102c66>] cpu_idle+0x26/0x70
  =======================
---[ end trace bbc6d0b1edc8c032 ]---

