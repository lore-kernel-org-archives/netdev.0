From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] rndis_host: Poll status channel before control channel
Date: Sat, 15 May 2010 14:37:15 +0100
Message-ID: <1273930635.2564.23.camel@localhost>
References: <1271718508.2197.12.camel@localhost>
	 <20100512.234259.35058609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-mybSuiYZ/34y1iTqmZfQ"
Cc: dbrownell@users.sourceforge.net, john.carr@unrouted.co.uk,
	netdev@vger.kernel.org, vzeeaxwl@myfairpoint.net,
	herton@mandriva.com.br
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58119 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753372Ab0EONh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 May 2010 09:37:28 -0400
In-Reply-To: <20100512.234259.35058609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mybSuiYZ/34y1iTqmZfQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-05-12 at 23:42 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 20 Apr 2010 00:08:28 +0100
>=20
> > Some RNDIS devices don't respond on the control channel until polled
> > on the status channel.  In particular, this was reported to be the
> > case for the 2Wire HomePortal 1000SW.
> >=20
> > This is roughly based on a patch by John Carr <john.carr@unrouted.co.uk=
>
> > which is reported to be needed for use with some Windows Mobile devices
> > and which is currently applied by Mandriva.
> >=20
> > Reported-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > Tested-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
> > ---
> > Note that this change hasn't yet been tested with any other RNDIS
> > devices.  John, can you confirm whether this also handles the WinMob
> > devices?
>=20
> Still waiting for this to get tested.  Is there really nobody in the
> world with RNDIS devices who can test this patch?  If so, maybe that's
> a good reason to not apply it :-))))

This has been in Debian unstable since 1 May and I haven't seen any
fall-out yet.  However I acknowledge that absence of evidence is not
evidence of absence.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-mybSuiYZ/34y1iTqmZfQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS+6jiue/yOyVhhEJAQInsw/+Mh1uOqB10X2gR/UfZAh7KFmPddrV9G5k
uPrl9PRMIvQcAw8ipP24ZtYwdZ5wlhipy7zqNprMaeRuG4mmqZMIq1755Tn5s2fQ
RHnISVLMI2GrbZOi6mWxbyQ7gWjc7gjvf5mH0+z2/OJa/Gzb8uRgSNRF2kI6tb6G
pPRH5qtRgkETLczvM8rXgDRTPKfu4AByKuKLsSIXqOdh0EOwj55ABeA7O83T7YRv
RvXNCU+yiwhB5+ZGqWE0khJzhYeR+A4Ss1+npCweLOl1gCdFhZn7N0qyn6lGFX8/
WHd+4DIQZbYFX9RVL15fbv+P+W1fEC2uNlLTvfN7UQVRwIhE2K8f7WxKDX1LU+J4
j8kYH+G7xaFUCYPvmoCo+FM91DKyb2CRBKe4bbLA/rhRF/25qkXuDIZe+bmsX+3m
o8JmKgB7MH52Ejz5mCnvnNu4AzWRxNfPZor4X47Hvt7OfKY6reMqe4pH7ZEggBEl
pX5cv4ODN7EXEuKbu6I5wijEFXp6id0TPFH2wS0JXzztt9Bkds4+bsgdvfQbcAhU
AHWkeVhkff+t3ZgfeN69bbGgPTg05mLk30C6VW6pxK0iRaIWUzkObFGeXrzlbj9n
vtNYnylmAb3PwnX/NOghW9XI8kRi/Fn+ZVYpvJ+RNvDeiKm4L5Ood/LpOFCW/QSN
QMUaKlSWXGk=
=V4cK
-----END PGP SIGNATURE-----

--=-mybSuiYZ/34y1iTqmZfQ--
