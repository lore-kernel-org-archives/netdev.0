From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 17:51:22 +0100
Message-ID: <1164559882.22909.5.camel@johannes.berg>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>
	 <45691273.9090803@gentoo.org> <1164535408.21459.3.camel@johannes.berg>
	 <4569C2D0.8080406@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QDidnRxeFTiD+N900daq"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62411 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1755448AbWKZQxn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 11:53:43 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4569C2D0.8080406@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QDidnRxeFTiD+N900daq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-26 at 11:37 -0500, Daniel Drake wrote:

> However the other reason for the patch (transmit=20
> queue needed for active scanning) is bogus,

I think that was just a misunderstanding.

> and the patch introduces a=20
> problem where session frames may be transmitted during scanning (using=20
> TX queue control avoids that problem).

Which is really the reason why we put that there in the first place :)

> Stack-level refcounted TX control like this would also be beneficial for=20
> zd1211rw, currently we have a semi-ugly implementation inside the driver.

> I agree with the objectives of this patch but the way I see it is that=20
> it trades one bug for another. A proper solution, as suggested by=20
> Johannes (refcounted stack-level TX control) would not be hard to=20
> implement and would solve the bug without introducing another.

Would you actually need a fully refcounted enable/disable? Because for
the stack it wouldn't be required if it'd simply not start scanning when
queue is disabled and stop scanning immediately when queue stop is
requested.

johannes

--=-QDidnRxeFTiD+N900daq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFacYK/ETPhpq3jKURAhOqAJ4nnixmp45y33Z6n6KoCGRyToR+oQCfcmsR
xdk9txb/gRipH+mdwQ3yfZY=
=F/rV
-----END PGP SIGNATURE-----

--=-QDidnRxeFTiD+N900daq--

