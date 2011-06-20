From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 20 Jun 2011 14:58:07 +1000
Message-ID: <20110620145807.9c202509.sfr@canb.auug.org.au>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
	<20110615085617.949d418f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__20_Jun_2011_14_58_07_+1000_BhR9.e35ucdTGR.a"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:33863 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866Ab1FTE6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 00:58:17 -0400
In-Reply-To: <20110615085617.949d418f.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__20_Jun_2011_14_58_07_+1000_BhR9.e35ucdTGR.a
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 15 Jun 2011 08:56:17 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Thu, 9 Jun 2011 14:56:57 +1000 Stephen Rothwell <sfr@canb.auug.org.au>=
 wrote:
> >
> > After merging the net tree, today's linux-next build (x86_64 allmodconf=
ig)
> > failed like this:
> >=20
> > [See summary in patch below.]
> >=20
> > I assume that this is fallout from commit a6b7a407865a ("net: remove
> > interrupt.h inclusion from netdevice.h").
> >=20
> > I added the following patch for today:
> >=20
> > From 520e46c255afa851b33e5c4a2bcf2112ecccbb6f Mon Sep 17 00:00:00 2001
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Thu, 9 Jun 2011 14:19:09 +1000
> > Subject: [PATCH] net/staging: add needed interrupt.h and hardirq.h incl=
udes
>=20
> I am still getting these build errors and applying the patch.  I would
> assume that if you merge Linus' tree (-rc3 will do it) into net-next, you
> will get these failures as well (for an x86_64 allmodconfig build at
> least).
>=20
> I think that this patch would probably apply to just the net-next tree
> anyway.

Ping.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__20_Jun_2011_14_58_07_+1000_BhR9.e35ucdTGR.a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN/tNfAAoJEDMEi1NhKgbs7osH/iS7PPd3DfdacFKi9gyyRjGI
RgaIBgiqLaQRgPRJ8qypGb9E8PHXRNztEnhLRXZh487rAYLpEOgwEyfPmxGFmkwm
junQ2/MJcxrg9x/g26P+9CczoHf/dTdvwNzsjDARnn2F/9P7aeWZklm/9PHzMZoF
n/C5V51IokGhQxH9hIcEYLgSdqlWeV/rmC77ETDDJH8dkmSh8rRBEjocIdpJshPM
j0k3qWRiFIBvhfNFyDVl7ZiJvJfW0rMYZOPi/MVkeivN4pXe4Kmq8T3XrOp9DhG9
eQ3IdEIcjDyRvW9RQLAHUsoEafCte4kKn7oOweuzl8DDehAozZ0KUrnZvEmT/vw=
=mrBq
-----END PGP SIGNATURE-----

--Signature=_Mon__20_Jun_2011_14_58_07_+1000_BhR9.e35ucdTGR.a--
