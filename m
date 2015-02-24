From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: mark constant as ULL
Date: Tue, 24 Feb 2015 04:23:45 -0800
Message-ID: <1424780625.2553.10.camel@jtkirshe-mobl>
References: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
	 <1423072177.2589.66.camel@jtkirshe-mobl> <54EB3F98.2030709@kpanic.de>
	 <54EC69B9.6020904@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-I9zn+LzFfCBtwy24iJr4"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30336 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577AbbBXMXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 07:23:46 -0500
In-Reply-To: <54EC69B9.6020904@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-I9zn+LzFfCBtwy24iJr4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-02-24 at 13:08 +0100, Stefan Assmann wrote:
> On 23.02.2015 15:56, Stefan Assmann wrote:
> > On 04.02.2015 18:49, Jeff Kirsher wrote:
> >> On Wed, 2015-02-04 at 12:41 +0100, Stefan Assmann wrote:
> >>> This avoids a compile error on 32bit.
> >>>
> >>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> >>> ---
> >>>  drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
> >>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> Come to find out, I already have a fix in my queue for this.  So I
> will
> >> be dropping your patch.
> >>
> >> The patch in my queue fixes the issue by doing the folling change:
> >> -               mask =3D 0xFFFFFFFFFFFFFFFF;
> >> +               mask =3D ~(u64)0;
> >>
> >=20
> > Jeff,
> >=20
> > this does not seem to compile on 32bit either. Please verify and if
> > you agree let's put my patch back in place instead of this one. IIRC
> > your patch has not been posted yet.
> >=20
> >   Stefan
> >=20
>=20
> Jeff,
>=20
> I fat fingered this, everything ok. Please ignore my last comment.

Ok, good to know.  I was wondering why our validation had not seen the
same issue.

--=-I9zn+LzFfCBtwy24iJr4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7G1RAAoJEOVv75VaS+3OY9IP/RbhoWEzm++UV09tcqc3J30A
Wvxjr2QzGEUtqgxPccI8agwUAI+nePC6NElHzfCY1l5D6ZUM1CZK15c0GSOPiYnt
CO2n/QJZOj0GMzm8jLhsq3SBEdkIABn7S8q9butAPF0E2P+clGoP1kEFqMzrAdwP
QOxJvasvj7HAtxB0YCmlpGZLDhIUbGAEadJ8thieB9g3MzoD99ZNZYBblhqWbmTV
+P3CEVZavKo/lCEFLIL/2oaoIeU0nfaPkTT+QUqNJTIuesWE9OlC74ATFf/PgLXh
tmpElWQ7o0BANJNEcYjHZJJoevccF2O/IpLjgYRv7A4YqFp3t87V+gSJtnPuJBJx
Y0350neYBDekI929H4sc3l26ifixCZjBpzQ5nIk0sxxcecWx/gosYZYL3OndQ568
/I8SXSOIHduQ7+ZjZ0BKM5cYK2w+fqwPNuQ6c2jzFLPeedoTGmj/pU4yQNg94sEc
d8jo+748qha1HG5tfDfwIUQu/rwUAibr5zy3LmeMuOVOy1mwN/kTxI6rXDxYqcxb
zxiwjoyuDnN0YnsE6HE38OXBdm4wZXe4rtfWxWHqoQBWP/wNha8JGiP9edftPrhN
dGFjW/jEycZmTyOYYiKC6676RMocbG//SRnMby999S+4SLIWny1zLZanAD86Vk16
Sn9cnW3ac7ijijLqNwt9
=ntOG
-----END PGP SIGNATURE-----

--=-I9zn+LzFfCBtwy24iJr4--
