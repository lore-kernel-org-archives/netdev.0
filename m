From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 30 Dec 2014 11:28:27 -0800
Message-ID: <1419967707.31582.23.camel@jtkirshe-mobl>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
	 <CAL3LdT73zfJwNcHS0ZpZ=ZzG=UiCUW5UEnOF9Fp2rR0e-ejXYg@mail.gmail.com>
	 <CAOYyTHb+5Wc-e3vBVE+MCh6YNfmompi9Mnsr0nDnHAn7Tvqyew@mail.gmail.com>
	 <1419965520.31582.20.camel@jtkirshe-mobl>
	 <CAOYyTHathHiGThyHj+yRi9O6jWEAO3wkAK-6egMc2OwK9dQoMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nvV1roFmA9yW3jXj1JDP"
Cc: netdev@vger.kernel.org, Gleb Natapov <gleb@cloudius-systems.com>,
	avi@cloudius-systems.com
To: Vladislav Zolotarov <vladz@cloudius-systems.com>,
	Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbaL3T3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 14:29:10 -0500
In-Reply-To: <CAOYyTHathHiGThyHj+yRi9O6jWEAO3wkAK-6egMc2OwK9dQoMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nvV1roFmA9yW3jXj1JDP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-30 at 21:00 +0200, Vladislav Zolotarov wrote:
>=20
> On Dec 30, 2014 8:52 PM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> wrote:
> >
> > On Tue, 2014-12-30 at 20:50 +0200, Vladislav Zolotarov wrote:
> > > On Dec 30, 2014 8:16 PM, "Jeff Kirsher"
> <jeffrey.t.kirsher@intel.com>
> > > wrote:
> > > >
> > > > On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
> > > > <vladz@cloudius-systems.com> wrote:
> > > > > Add the ethtool ops to VF driver to allow querying the RSS
> > > indirection table
> > > > > and RSS Random Key.
> > > > >
> > > > >  - PF driver: Add new VF-PF channel commands.
> > > > >  - VF driver: Utilize these new commands and add the
> corresponding
> > > > >               ethtool callbacks.
> > > > >
> > > > > Vlad Zolotarov (5):
> > > > >   ixgbe: Add a RETA query command to VF-PF channel API
> > > > >   ixgbevf: Add a RETA query code
> > > > >   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
> > > > >   ixgbevf: Add RSS Key query code
> > > > >   ixgbevf: Add the appropriate ethtool ops to query RSS
> > > indirection
> > > > >     table and key
> > > > >
> > > > >  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
> > > > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60
> > > +++++++++++
> > > > >  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37
> +++++++
> > > > >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
> > > > >  drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
> > > > >  drivers/net/ethernet/intel/ixgbevf/vf.c           | 125
> > > ++++++++++++++++++++++
> > > > >  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
> > > > >  7 files changed, 243 insertions(+), 1 deletion(-)
> > > >
> > > > Remember to CC on patches against drivers in
> > > drivers/net/ethernet/intel/ please.
> > >
> > > To CC who? ;)
> > >
> >
> > Sorry, I fat fingered that response.  Please CC me.
>=20
> Sure. NP.=20
> Since we are talking already, could u comment on the RFC? Does it look
> ok to you?=20
>=20
>=20

I have provided feedback on 3 of the patches, the others look ok to me.
I would like Greg Rose to look over your changes since he did most of
the ixgbevf work, and I want to make sure that he is fine with these
changes.

--=-nvV1roFmA9yW3jXj1JDP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUovzbAAoJEOVv75VaS+3OaywP/RGjKUzAMDOtEzz6v1ev12Jm
WgBfmS3KB2A83cCFjkKWML2MZK2Zqx6Tt1uzlHfAmfnLU9kUIhvaK6QB2KYzZU+s
jdtLfqthbhdf/EY2YMVvVtvvhmI5dTWtx7q04wa4tEYQh5oYMUAgAISvYimRQ2Ij
ZO5cKWop8c2g+uDeGNnN9a5SghiBAcGbkj90pnfALAmEGnSpXNU2S68gf9DaanaH
PPQmNlieWxbitvyx+CvNI227SfvVKvGB3fuu4SVxZWfRSdMegLjbD/TG+h4d5ut4
brYe6ehFyTPgEru6C/pbUBd9mnnJ4brC0cQMroDhQCXJgpT7c4qTR67wbnlrTuXj
jYatbFK5V1cyP7dxv6FgtIhb3OdujK3NdX/za9U/hNQWzZURm/8dC8VYfr/2VvvD
/jj5cqG9OP9VsRJ7MUBSRI4zqIE+terYJWRmmBJwTchJoRMyWchTv+BXMg5iNtrA
hv1xNv4ZJ+T1QV+XB5T8WPZFx3s2vz+D8c8hv3fMW+ERf3Le6lNI0HHFK8kx/Y/9
zruHB8A7dXLOvxacjov4TOBdtQvZsiZf/ArOBzad0X9t38I72prXqWKif3ZHLenx
QE4Cfz41t+Dm2LjqWlxJ+I56ad+VKUXDVJ6Gu4vfAcwr0xg2JM7O5IUvT71mOIaE
FBbANAmoJYROtyd4aS+X
=shQg
-----END PGP SIGNATURE-----

--=-nvV1roFmA9yW3jXj1JDP--
