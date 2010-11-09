From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 22:35:24 +0100
Message-ID: <4CD9BE9C.30003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49176 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab0KIVf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 16:35:28 -0500
Received: by wyb36 with SMTP id 36so5276460wyb.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 13:35:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:

> To fix this I added "-q 0" to netcat.  Thus my working commands are:
>=20
>  netcat -l -p 9999 >/dev/null &
>  time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat -q0 127.0.0.1 =
9999
>=20
> Running this on my "big" 10G testlab system, Dual Xeon 5550 2.67GHz,
> kernel version 2.6.32-5-amd64 (which I usually don't use)
> The results are 7.487 sec:

netcat flavor ?

http://nc110.sourceforge.net/
http://nmap.org/ncat/
http://www.dest-unreach.org/socat/
http://cryptcat.sourceforge.net/
http://netcat.sourceforge.net/
http://www.openbsd.org/cgi-bin/cvsweb/src/usr.bin/nc/

--=20
=ABAll=E1 muevan feroz guerra, ciegos reyes por un palmo m=E1s de tierr=
a;
que yo aqu=ED tengo por m=EDo cuanto abarca el mar brav=EDo, a quien na=
die
impuso leyes. Y no hay playa, sea cualquiera, ni bandera de esplendor,
que no sienta mi derecho y d=E9 pecho a mi valor.=BB
