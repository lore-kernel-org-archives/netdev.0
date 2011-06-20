From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 21:02:58 -0700
Message-ID: <1308542579.22851.46.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <1308536729.22851.42.camel@jtkirshe-mobl>
	 <1308540132.11457.97.camel@localhost>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-oFzYfS+DkS/yQpf0sTyZ"
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5219 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811Ab1FTEDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 00:03:00 -0400
In-Reply-To: <1308540132.11457.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oFzYfS+DkS/yQpf0sTyZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-06-19 at 20:22 -0700, Ben Hutchings wrote:
> On Sun, 2011-06-19 at 19:25 -0700, Jeff Kirsher wrote:
> > On Wed, 2011-06-15 at 18:10 -0700, Joe Perches wrote:
> [...]
> > > Some manufacturer directories are directly populated
> > > with multiple drivers, some have subdirectories.
> > > Should one style be consistently used?
> >=20
> > This is a grey area.  I think it makes more sense to group drivers
> > either by company, maintainer, bus or commonly used header.  It has bee=
n
> > expressed by others in the community and while placing drivers in
> > driver/net/ethernet/<company name> is nice way to organize, companies
> > get bought and sold and driver ownership moves from one company to
> > another.  To constantly rename directories based on the ownership may
> > cause un-necessary flux in the directory structure.  I tried to tried t=
o
> > avoid using company names unless I was confident about it.
>=20
> You could try to futureproof by leaving out companies altogether and
> just considering the technical heritage of hardware.  For example, the
> netxen and qlcnic drivers appear to work with related hardware, but qlge
> and qlcnic do not.  But this is possibly not a lot more objective than
> what you've done so far, and it doesn't make it any easier to name the
> directories.
>=20
> > Some of the suggestions you listed below seem fine, especially since
> > several of these companies have been around for some time and actively
> > maintain their driver(s).
> [...]
> > > sfc may be solarflare
> [...]
>=20
> This directory only contains a single net driver, and its name matches
> the prefix for Solarflare controller part numbers (not LOMs, but the
> driver doesn't care about the distinction).  Any separate driver for
> future Solarflare hardware is also likely to be named beginning with the
> letters 'sfc'.  So I'd be happier if this was *not* renamed.
>=20
> Ben.
>=20

Thanks Ben, I will keep it sfc.

--=-oFzYfS+DkS/yQpf0sTyZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/sZyAAoJECTsCADr/EWUUg8H/RUZabnp+UqVnbpwxQvMEdKv
afzP8qGXkuM6WwYkSce96cMJYdO4JoxAoArDzhkEfNUDr7Vl/Vmk9i8L4wFE9XVT
RS7hlzAfCu87scLNvPn79fEqZ8sn78fmZENy/YeiZKMfqwYw+DFZYxiVsx8VRgJV
zl27UWFQI5D21Snu2ByAqdXjVGcXIzaPxdSaH6HfJgpkwpODJtN4bAXhw79KZW8N
gR2ZfO9b1jLnqvU5VGv2WCvaEV2AbbT/DfkulG8OCiyfMaiFxJGgZHzYcnVftV3U
k45oCvfjtkQ5DhLf7DZhGdc7gZlB7IBelZI+teAj8Nb6QJvIt2PGuoIQh2yDEGI=
=PVW8
-----END PGP SIGNATURE-----

--=-oFzYfS+DkS/yQpf0sTyZ--

