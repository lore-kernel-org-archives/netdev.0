From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Segmentation fault when using ping6
Date: Thu, 07 Oct 2010 14:36:30 +0200
Message-ID: <1286454990.2912.153.camel@edumazet-laptop>
References: <4CADBC7A.6060908@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55658 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab0JGMgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 08:36:35 -0400
Received: by fxm4 with SMTP id 4so291702fxm.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 05:36:34 -0700 (PDT)
In-Reply-To: <4CADBC7A.6060908@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 09:26 -0300, Rogerio Pimentel a =C3=A9c=
rit :
> Hi,
>=20
> I'm having a "segmentation fault" problem when using ping6.
>=20
> When testing on ARM9 platforms (i.MX25 and i.MX27), it returns the er=
ror:
>=20
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> Segmentation fault
>=20
> When testing on ARM11 and ARM Cortex A8 platforms (i.MX31 and i.MX51)=
,=20
> it works:
>=20
> root@freescale ~$ ping6 ::1
> PING ::1 (::1): 56 data bytes
> 64 bytes from ::1: seq=3D0 ttl=3D64 time=3D0.331 ms
> 64 bytes from ::1: seq=3D1 ttl=3D64 time=3D0.214 ms
> 64 bytes from ::1: seq=3D2 ttl=3D64 time=3D0.176 ms
> 64 bytes from ::1: seq=3D3 ttl=3D64 time=3D0.155 ms
>=20
> On all cases, I'm using Linux Kernel 2.6.35 (from Mainline) and Busyb=
ox=20
> 1.15.0
>=20
> Does anybody have any idea?

Do you have something displayed on console ? ( dmesg output )

gdb could tell you where segmentation takes place.


