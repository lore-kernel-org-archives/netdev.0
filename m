From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Mon, 13 Feb 2012 21:18:13 +0100
Message-ID: <1329164293.2523.0.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43185 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab2BMUSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 15:18:17 -0500
Received: by werb13 with SMTP id b13so3727162wer.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 12:18:16 -0800 (PST)
In-Reply-To: <8633039.fHPLx6GNq3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 f=C3=A9vrier 2012 =C3=A0 22:04 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> Hi,
>=20
> I noticed that with 3.2.x kernels download speed from some internet r=
esources
> became about half of speed that was with previous kernels (3.1 and ol=
der).
> I tested Fedora 15 kernels 2.6.41.10 =3D 3.1.10 and 2.6.42.3 =3D 3.2.=
3
> (many times rebooted for testing with first and second kernels).
> See bug https://bugzilla.redhat.com/show_bug.cgi?id=3D789659
>=20
> lsmod:
> Module                  Size  Used by
> nvidia              10778232  40
> i2c_core               28123  1 nvidia
> 8139too                32490  0
> mii                    13311  1 8139too
>=20
> dmesg:
> 8139too: 8139too Fast Ethernet driver 0.9.28
> 8139too 0000:01:02.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> 8139too 0000:01:02.0: eth0: RealTek RTL8139 at , IRQ 22
> 8139too 0000:01:02.0: eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
>=20
> For testing I selected fastest for me download mirrors of FreeBSD and=
 Ubuntu,
> also I tested download speed from site speedtest.tele2.net.
>=20
> For these sites download speed with 3.1 kernels (and older) is about =
11 MB/s
> but with 3.2.x kernels - limited 5.5 MB/s and for some sites still ap=
proximately
> the same as with 3.1 kernels (see bug mentioned above).
>=20

MB/s means MBytes or Mbits ?

> Also I want to pay attention that limited speed stays constant - alwa=
ys
> 5.5 MB/s with straight line on traffic plotter as if was network band=
width shaping.
> With 3.1 kernels this never happens - speed can vary in some ranges
> but at maximum it is about 11 MB/s, no limitations such as 5.5 MB/s.
>=20

Could you post "netstat -s" result ?
