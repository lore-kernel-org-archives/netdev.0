From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Sat, 12 Dec 2009 08:15:11 +0100
Message-ID: <4B2342FF.6020008@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com> <4B22C075.2020902@gmail.com> <4B22C4CD.8010402@gmail.com> <4B22DBE0.1020104@gmail.com> <4B22EC9C.70207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Constantine <kevin.constantine@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43915 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbZLLHPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 02:15:08 -0500
In-Reply-To: <4B22EC9C.70207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2009 02:06, Kevin Constantine a =E9crit :
> Here's another crash from while the machine was sitting idly at the
> login prompt.
>=20
>=20
> debian login: Unable to handle kernel paging request at virtual addre=
ss
> 183d84a0
> pgd =3D c0004000
> [183d84a0] *pgd=3D00000000
> Internal error: Oops: 0 [#1] PREEMPT
> Modules linked in: spidev atmel_spi
> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #16)
> PC is at 0x183d84a0
> LR is at __udp4_lib_rcv+0x43c/0x72c
> pc : [<183d84a0>]    lr : [<c024e91c>]    psr: 40000013
> sp : c037fe70  ip : c037fe20  fp : c0384e60
> r10: 00000008  r9 : c03bad00  r8 : 00000000
> r7 : c03bb0ec  r6 : c03baaa4  r5 : c1ec2500  r4 : c03a06f0
> r3 : 00000000  r2 : c037e000  r1 : 00000075  r0 : 00000000
> Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: c000717f  Table: 21d58000  DAC: 00000017
> Process swapper (pid: 0, stack limit =3D 0xc037e268)
> Stack: (0xc037fe70 to 0xc0380000)
> fe60:                                     c1d17800 c1da5c30 c1ec2500
> c03a077c
> fe80: c1d17800 c022dc58 c1d17800 00000001 c1df6400 c026e4d8 c03bace0
> c1ec2500
> fea0: c03a077c c1d17800 00000000 c0214ed0 c0037100 c0034388 00000001
> c039e54c
> fec0: 0005bedc 00000040 00000000 c039e534 c039e530 c0214fb4 00000001
> c039e54c
> fee0: 00000040 c037e000 0000012c c039e530 c03bacf0 0005bede c039e540
> c0213764
> ff00: c1ec2500 00000103 0000000c c037e000 00000001 c03a8678 00000000
> 0000000a
> ff20: 00000000 c0040358 c037e000 2001ccb8 00000000 00000018 00000000
> 00000018
> ff40: 00000002 00000001 c037e000 2001ccb8 00000000 c0040428 00000018
> c0022060
> ff60: 00000000 ffffffff fefff000 c0022a3c 00000000 00000001 00000080
> 60000013
> ff80: c00243a4 c037e000 c0381e7c c00243a4 c03a3ac8 41129200 2001ccb8
> 00000000
> ffa0: fefff800 c037ffb8 c00243e0 c00243ec 60000013 ffffffff c00243a4
> c0024368
> ffc0: c03ab174 c03a3a90 c001ed30 c0381cc8 2001ccec c00088d4 c0008434
> 00000000
> ffe0: 00000000 c001ed30 c0007175 c03a3af8 c001f134 20008034 00000000
> 00000000
> Code: bad PC value.
> Kernel panic - not syncing: Fatal exception in interrupt
> [<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b1dfc>]
> (panic+0x3c/0x120)
> [<c02b1dfc>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
> [<c0026e60>] (die+0x154/0x180) from [<c0029848>]
> (__do_kernel_fault+0x68/0x80)
> [<c0029848>] (__do_kernel_fault+0x68/0x80) from [<c0029a74>]
> (do_page_fault+0x214/0x234)
> [<c0029a74>] (do_page_fault+0x214/0x234) from [<c0022b40>]
> (__pabt_svc+0x40/0x80)
> [<c0022b40>] (__pabt_svc+0x40/0x80) from [<c024e91c>]
> (__udp4_lib_rcv+0x43c/0x72c)
> [<c024e91c>] (__udp4_lib_rcv+0x43c/0x72c) from [<c039e54c>] (0xc039e5=
4c)
> --=20

This one happens frequently.

A disassembly of whole __udp4_lib_rcv() function could help.

Could you please send _me_ the vmlinux file, or an url on it ?

Thanks
