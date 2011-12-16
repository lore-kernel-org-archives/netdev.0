From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter show not displaying anything
Date: Fri, 16 Dec 2011 14:06:35 -0500
Message-ID: <1324062395.8451.332.camel@denise.theartistscloset.com>
References: <1324010915.8451.319.camel@denise.theartistscloset.com>
	 <1324012627.2562.26.camel@edumazet-laptop>
	 <1324013969.8451.326.camel@denise.theartistscloset.com>
	 <1324014178.2562.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:60422 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760028Ab1LPTGj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:06:39 -0500
In-Reply-To: <1324014178.2562.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 06:42 +0100, Eric Dumazet wrote:
> Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 00:39 -0500, John A. Sulliva=
n III a
> =C3=A9crit :
>=20
> > Ouch! That was right out of the book so to speak.  Thanks for point=
ing
> > it out - now I see it is right in the man page.  Is best practice t=
o not
> > perturb and live with the potentially unbalanced queues or just to =
set
> > it even higher? Thanks - John
> >=20
>=20
> I'll fix this today, because rehashing up to 128 packets is not that
> expensive.
>=20
> In the meantime, just use a higher timer (say 60 seconds), and if you=
r
> kernel is recent enough, use a higher 'divisor' value (default 1024, =
can
> be up to 65536) to lower risk of hash collisions.
<snip>
Thanks.  Alas, no divisor parameter in Debian Squeeze:
sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]
