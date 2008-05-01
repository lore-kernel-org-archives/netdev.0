From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Thu, 01 May 2008 10:54:10 +0100
Message-ID: <48199342.9010406@andyfurniss.entadsl.com>
References: <4815BCDF.6070704@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi> <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi> <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:59177 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758525AbYEAJyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 05:54:17 -0400
In-Reply-To: <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Thu, 1 May 2008, Andy Furniss wrote:
>=20
>> Caught one -
>>
>>
>> May  1 03:35:45 noki kernel: 4l2_common ir_kbd_i2c ir_common tveepro=
m
>=20
> Things above this got lost somewhere?

No - well not by the paste, I selected either side when pasting and=20
edited them out of the mail. I did notice that and double checked - it=20
is the first May 1 in my kernel log.

Apr 30 21:23:13 noki kernel: br0: topology change detected, propagating
Apr 30 21:23:13 noki kernel: br0: port 2(eth1) entering forwarding stat=
e
May  1 03:35:45 noki kernel: 4l2_common ir_kbd_i2c ir_common tveeprom=20
videobuf_dvb dvb_core videobuf_dma_sg videobuf_core nxt200x isl6421=20
tda1004x firmware_class tda827x cls_flow sch_ingress xt_mark xt_length=20
xt_MARK cls_u32 sch_sfq cls_fw sch_htb ipt_REJECT xt_state=20
iptable_filter xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle nf_nat_ftp=20
nf_conntrack_ftp iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv=
4=20
nf_conntrack bridge llc container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #=
2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144]=20
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840]=20
tcp_transmit_skb+0x47d/0x730
