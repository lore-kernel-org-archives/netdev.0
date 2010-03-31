From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
  mode
Date: Wed, 31 Mar 2010 17:14:08 +0200
Message-ID: <1270048448.2103.28.camel@edumazet-laptop>
References: <20100325214033.GA28741@gospo.rdu.redhat.com>
	 <1270026517.2103.9.camel@edumazet-laptop>
	 <m2x7b667921003310749v5c8b6e62g7339eff24a51e6d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lhh@redhat.com, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:49088 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab0CaPON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 11:14:13 -0400
Received: by bwz1 with SMTP id 1so155907bwz.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 08:14:12 -0700 (PDT)
In-Reply-To: <m2x7b667921003310749v5c8b6e62g7339eff24a51e6d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 31 mars 2010 =C3=A0 10:49 -0400, Andy Gospodarek a =C3=A9cr=
it :

> Curious what version of GCC are you using?  Before applying your patc=
h
> it compiles without warning on my x86_64 F11-ish system with:
>=20
> gcc version 4.4.1 20090725 (Red Hat 4.4.1-2) (GCC)
>=20

ARCH=3Dx86_64 CROSS_COMPILE=3Dx86_64-unknown-linux- make vmlinux

so, it was a cross compiler :

/data/x86-64/bin/x86_64-unknown-linux-gcc-4.1.2 -v
Using built-in specs.
Target: x86_64-unknown-linux
Configured with: ../gcc-4.1.2/configure --prefix=3D/data/x86-64
--target=3Dx86_64-unknown-linux --enable-languages=3Dc --disable-shared
--disable-multilib --disable-threads --disable-libssp --without-headers
--disable-libmudflap
Thread model: single
gcc version 4.1.2




