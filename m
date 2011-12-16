From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc filter show not displaying anything
Date: Fri, 16 Dec 2011 06:42:58 +0100
Message-ID: <1324014178.2562.33.camel@edumazet-laptop>
References: <1324010915.8451.319.camel@denise.theartistscloset.com>
	 <1324012627.2562.26.camel@edumazet-laptop>
	 <1324013969.8451.326.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44836 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1LPFoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:44:22 -0500
Received: by wgbdr13 with SMTP id dr13so5502651wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 21:44:21 -0800 (PST)
In-Reply-To: <1324013969.8451.326.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 00:39 -0500, John A. Sullivan =
III a
=C3=A9crit :

> Ouch! That was right out of the book so to speak.  Thanks for pointin=
g
> it out - now I see it is right in the man page.  Is best practice to =
not
> perturb and live with the potentially unbalanced queues or just to se=
t
> it even higher? Thanks - John
>=20

I'll fix this today, because rehashing up to 128 packets is not that
expensive.

In the meantime, just use a higher timer (say 60 seconds), and if your
kernel is recent enough, use a higher 'divisor' value (default 1024, ca=
n
be up to 65536) to lower risk of hash collisions.
