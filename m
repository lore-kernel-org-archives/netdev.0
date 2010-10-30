From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 29 Oct 2010 17:01:59 -0700
Message-ID: <1288396919.15283.23.camel@jtkirshe-MOBL1>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	 <1288316896.1836.41.camel@Joe-Laptop>  <4CCB3BF1.7070000@windriver.com>
	 <1288390127.28828.225.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-KU1hSiYlKcVq7cOeQh3L"
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33303 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209Ab0J3AB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 20:01:59 -0400
In-Reply-To: <1288390127.28828.225.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KU1hSiYlKcVq7cOeQh3L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-10-29 at 15:08 -0700, Joe Perches wrote:
> On Fri, 2010-10-29 at 17:26 -0400, Paul Gortmaker wrote:
> > On 10-10-28 09:48 PM, Joe Perches wrote:
> > > On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
> > >> The drivers/net dir has a lot of files - originally there were
> > >> no subdirs, but at least now subdirs are being used effectively.
> > >> But the original drivers from 10+ years ago are still right
> > >> there at the top.  This series creates a drivers/net/legacy dir.
> > > I like this idea.
> > > I suggest a bit of a further grouping by using a
> > > drivers/net/ethernet directory and putting those
> > > legacy drivers in a new subdirectory
> > > drivers/net/ethernet/legacy.
> > That is a substantially larger change, since you'd now be
> > relocating nearly every remaining driver, i.e. all the
> > relatively modern 100M and GigE drivers.
>=20

I am not particularly a fan of making a "legacy" directory and moving
old drivers into it.  Just because this is very subjective, if you say
"drivers which are X years old and not used much" is vague and depending
on who you ask would get varying results.  But if you were to were to
define legacy as all ISA, EISA and MCA drivers (not based on their use)
would be better.

But if a legacy directory was to be made, I like Joe's suggestion of
drivers/net/ethernet/legacy.

> Files to not need immediate renames.
>=20
> Renames could happen when the appropriate maintainer
> wants to or gets coerced to conform to some new
> file layout standard.
>=20
> I had submitted a related RFC patch:
>=20
> https://patchwork.kernel.org/patch/244641/
>=20
> and then had some off list discussions
> with Jeff Kirsher from Intel.
>=20
> Perhaps Jeff will chime in.
>=20
> > Plus what do you
> > do with the sb1000 - create drivers/cablemodem/legacy
> > just for one file?
>=20
> I never looked at that particular driver before.
> Maybe.  I don't have a strong opinion.  Leaving
> it where it is might be OK.
>=20
> > Or the ethernet drivers already in
> > existing subdirs, like arm and pcmcia -- do we move those?
>=20
> Maybe.  If there's no demand, there's no absolute need to
> move it at all.  I think a reasonable goal is to have some
> sensible and consistent file layout scheme though.
>=20
> There are arch specific directories under various drivers/...
> so I don't see a need to move directories like drivers/net/arm
> or drivers/s390.

I agree with Joe.

>=20
> > With this, I tried to aim for a significant gain (close to 1/3
> > less files) within what I felt was a reasonable sized change
> > set that had a chance of getting an overall OK from folks.
> > Giant "flag-day" type mammoth changesets are a PITA for all.
>=20
> I believe there's no need for a flag-day.
> File renames could happen gradually or not at all.
>=20
>=20

Again I agree with Joe.


--=-KU1hSiYlKcVq7cOeQh3L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJMy2B3AAoJECTsCADr/EWU9Z0H/2V8jwBCl4GJc1mm0hkgE6r3
WmtE7u0daOlkuPIhm1b2U9hu0KrnnX3REiY/cTWntkkSa6ZuspEwbCQf+HWa4bfD
tMjcxJ/xHiKZJajDNeBJDbjw0CUqS7PQRw2F2Fw8Jn7awaUfkwNUehan1EVLKA5V
ZBXPPITp1yuMrAlY+OxhKlDTAMNGEkv9/04HV76Qo17RRw5drCeW4ISK2Wz2QK7I
ypJ5iB3d76PoC4gLC3XrFnKx7iOWmssXZzL3bat0yuMUsB+l9VN1NQ0Ce6D1lRr/
qmKcZ0i8TnXEB/njaX9A4urlFjnfXD1Vk1n/y9m5mY/p0i+4YkgIhDTGKu0h5Kc=
=6d9m
-----END PGP SIGNATURE-----

--=-KU1hSiYlKcVq7cOeQh3L--

