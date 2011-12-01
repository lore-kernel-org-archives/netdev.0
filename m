From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] netem: fix build error on 32bit arches
Date: Thu, 01 Dec 2011 12:19:15 +0100
Message-ID: <1322738355.2335.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEF7@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35626 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab1LALTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 06:19:19 -0500
Received: by vbbfc26 with SMTP id fc26so1283073vbb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 03:19:18 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEF7@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 11:04 +0000, David Laight a =C3=A9=
crit :
> > +	u64 ticks =3D (u64)len * NSEC_PER_SEC;
> Writing:
> 	u64 ticks =3D len * (u64)NSEC_PER_SEC;
> probably generates better code since the compiler
> is much more likely to spot that a single 32x32 -> 64
> multiply is adequate.
>=20

Your copy if gcc is very dumb then :)
