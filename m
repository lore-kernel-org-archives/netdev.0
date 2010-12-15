From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.37-rc5] Build error on parisc.
Date: Wed, 15 Dec 2010 19:22:48 +0100
Message-ID: <1292437368.3427.389.camel@edumazet-laptop>
References: <201012150801.oBF81EVm047830@www262.sakura.ne.jp>
	 <20101215.101925.71116399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60128 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0LOSXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 13:23:00 -0500
Received: by wyb28 with SMTP id 28so1736324wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 10:22:59 -0800 (PST)
In-Reply-To: <20101215.101925.71116399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 10:19 -0800, David Miller a =C3=
=A9crit :
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 15 Dec 2010 17:01:14 +0900
>=20
> > [2.6.37-rc5] Build error on parisc.
> >=20
> > Commit 5635c10d "net: make sure struct dst_entry refcount is aligne=
d on 64 bytes"
> > uses manual padding. I triggered BUILD_BUG_ON() when using
> > http://kernel.org/pub/tools/crosstool/files/bin/i686/4.5.1/i686-gcc=
-4.5.1-nolibc_hppa64-linux.tar.bz2 .
> >=20
> >   make -s CROSS_COMPILE=3Dhppa64-linux- ARCH=3Dparisc
> >=20
> >   include/net/dst.h: In function 'dst_hold':
> >   include/net/dst.h:161:2: error: negative width in bit-field '<ano=
nymous>'
> >=20
> > I think below patch can fix the error but that commit says that we =
cannot use
> > __atribute((aligned)). Why?
>=20
> We don't want to create holes of unused space in the structure, we wa=
nt
> to know exactly how every byte of space is being used so nothing is
> wasted when all features are enabed.

Yes, sorry for missing your mail Tetsuo.



