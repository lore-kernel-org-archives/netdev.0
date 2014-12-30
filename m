From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 30 Dec 2014 10:52:00 -0800
Message-ID: <1419965520.31582.20.camel@jtkirshe-mobl>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
	 <CAL3LdT73zfJwNcHS0ZpZ=ZzG=UiCUW5UEnOF9Fp2rR0e-ejXYg@mail.gmail.com>
	 <CAOYyTHb+5Wc-e3vBVE+MCh6YNfmompi9Mnsr0nDnHAn7Tvqyew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7YRaausoph2FiNcG6RYa"
Cc: Gleb Natapov <gleb@cloudius-systems.com>, netdev@vger.kernel.org,
	avi@cloudius-systems.com
To: Vladislav Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64071 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbaL3SwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 13:52:03 -0500
In-Reply-To: <CAOYyTHb+5Wc-e3vBVE+MCh6YNfmompi9Mnsr0nDnHAn7Tvqyew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7YRaausoph2FiNcG6RYa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-30 at 20:50 +0200, Vladislav Zolotarov wrote:
> On Dec 30, 2014 8:16 PM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> wrote:
> >
> > On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
> > <vladz@cloudius-systems.com> wrote:
> > > Add the ethtool ops to VF driver to allow querying the RSS
> indirection table
> > > and RSS Random Key.
> > >
> > >  - PF driver: Add new VF-PF channel commands.
> > >  - VF driver: Utilize these new commands and add the corresponding
> > >               ethtool callbacks.
> > >
> > > Vlad Zolotarov (5):
> > >   ixgbe: Add a RETA query command to VF-PF channel API
> > >   ixgbevf: Add a RETA query code
> > >   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
> > >   ixgbevf: Add RSS Key query code
> > >   ixgbevf: Add the appropriate ethtool ops to query RSS
> indirection
> > >     table and key
> > >
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60
> +++++++++++
> > >  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37 +++++++
> > >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
> > >  drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
> > >  drivers/net/ethernet/intel/ixgbevf/vf.c           | 125
> ++++++++++++++++++++++
> > >  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
> > >  7 files changed, 243 insertions(+), 1 deletion(-)
> >
> > Remember to CC on patches against drivers in
> drivers/net/ethernet/intel/ please.
>=20
> To CC who? ;)
>=20

Sorry, I fat fingered that response.  Please CC me.

--=-7YRaausoph2FiNcG6RYa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUovRQAAoJEOVv75VaS+3OQqEQAJdmZXIDMN8SVbsFg6eBcPgV
Huvh1mZ8Hyi4s/F3mjwfrLFQVqHVwrPG0PK0LRq5aAh7dXL18h97rWjBGd6zOce8
G8tKCNSpV2JACvNtOHDoabt/YA1tfPFQuwphu4rojLRqvkYgObxCbKkRas+GJTKL
09HbXLazO0p5l950RB3Fz12NPV9/lib4M6/+yXt4xfd0uZcYibTdwtbcym+vqihT
XCKf3NyDHyGg1Ly+j3mzR6lajkvUjfwNykKn6ZX84uJPe6vUFBZmBZM7m1CdzRCP
KE2VnXWdlG6DaZ/YwRHiglgTsMFZvkP9QDmAjhyHOo6/Pme72EjdgRm2F93aHLaC
WMm6XsH5x4xnTQ2XFMA9ZCC2Y00tdgMONAmK/hGryZ300Fh+JgSy8li0X4FHEKxL
FBr73RxAYdBO95kXy452VCOBY88SwM/k/dQwZlteOOKiQMYAzQ5PzNflt8l/oiXP
VEnAyhz6ridgBTjHq7jKZtUXyDheRFfcr3ZxRhKr97KeY1t6tuKyRhejecr+i0nY
WjQRYC2VnjKskDJYpKO4zTqf+LH+MMkUJJ27MNIH3RTyzqAW+xrsLrANsmW16/TI
q8L3kGrdPP/sf0J8cmBfeoZdTDXsqwNJUg6wNTmUF9Y/zNS67168zeRXUF/Ln2+V
0zQiBOEhDnsaiz2fBsiV
=8gvD
-----END PGP SIGNATURE-----

--=-7YRaausoph2FiNcG6RYa--
