From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Thu, 1 May 2008 12:37:30 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
References: <4815BCDF.6070704@andyfurniss.entadsl.com>
 <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
 <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
 <481986FD.8070108@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Andy Furniss <lists@andyfurniss.entadsl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44299 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbYEAJhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 05:37:36 -0400
In-Reply-To: <481986FD.8070108@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 May 2008, Andy Furniss wrote:

> Caught one -
> 
> 
> May  1 03:35:45 noki kernel: 4l2_common ir_kbd_i2c ir_common tveeprom

Things above this got lost somewhere?

> videobuf_dvb dvb_core videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x
> firmware_class tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32
> sch_sfq cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss
> xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat ip_tables
> nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc container fan
> thermal processor button tulip
> May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
> May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144]
> warn_on_slowpath+0x5f/0x90
> May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840]
> tcp_transmit_skb+0x47d/0x730
> May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944]
> tcp_verify_wq+0x35f/0x3b0
> May  1 03:35:45 noki kernel:  [tcp_xmit_retransmit_queue+346/976]
> tcp_xmit_retransmit_queue+0x15a/0x3d0
> May  1 03:35:45 noki kernel:  [tcp_ack+4069/7232] tcp_ack+0xfe5/0x1c40
> May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840]
> tcp_rcv_established+0x3de/0x730
> May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] tcp_v4_do_rcv+0xb3/0x1d0
[...snip...]
> May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
> May  1 03:35:45 noki kernel: P: 4 L: 1 vs 1 S: 3 vs 3 F: 4 vs 6 w:
> 2200787703-2200792303 (7)

Thanks, a genuine one, fackets_out (= 6) > packets_out (= 4). :-)
...I'll try to figure it out anyway.

-- 
 i.

