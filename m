From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 2/2] igb: Add Support for new i210/i211 devices.
Date: Fri, 11 May 2012 16:02:37 -0700
Message-ID: <1336777357.3055.41.camel@jtkirshe-mobl>
References: <1336723282-3130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1336723282-3130-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120511.182735.63933163877487008.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SPwVTu4AvUcvAusFtjU1"
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57852 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab2EKXCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2012 19:02:38 -0400
In-Reply-To: <20120511.182735.63933163877487008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SPwVTu4AvUcvAusFtjU1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-05-11 at 18:27 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 11 May 2012 01:01:22 -0700
>=20
> > +s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
> > +{
> > +	s32 ret_val;
> > +
> > +	ret_val =3D igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
> > +
> > +	return ret_val;
> > +}
>=20
> Please, this is just unnecessary syntactic masterbation, simplify this
> to:
>=20
> s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
> {
> 	return igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
> }
>=20
> And:
>=20
> > +void igb_release_nvm_i210(struct e1000_hw *hw)
> > +{
> > +
> > +	igb_release_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
> > +}
>=20
> Please get rid of that unnecessary empty line.
>=20
> I can really tell when someone is extremely careless when removing
> their debugging code, and I can almost guarentee that's what has
> happened here.

Dave,

I get this cleaned up for Carolyn.  I will wait to re-submit till later
tonight to ensure that there is no other feedback or comments that need
to be addressed.

Cheers,
Jeff

--=-SPwVTu4AvUcvAusFtjU1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPrZqNAAoJEOVv75VaS+3OzfYP/A76CvXoOnLb/cN0oCtijrtC
hTpRxjUhxBTVLEsuJngahkbGl4s7/c5CQPcTad8C6XQ5p69k35Wzuc2LTvbr+NRi
oQnLSOAJ9UU14yrihhlSgmvo49e55i/ApJ0MWjvvKKE+50fAzQ2DSstRsCFR6YfT
4BK9hhdWHSh3MhWGS72jxYopYSAH0jq1ERr7n+W9/F4Fyhq4zNfNje5cFQg9MIlv
dBGCyXnQRCNnKRBn3YtayBaVW0SqscDKx4xATybFmvwhTkl775AOpSK+ZrvrP+zC
nSUw0sope5NZhgGXRmh2yB0SgJyHy9eVi/jAUbPnOIDK9V8vsQG5qTxmQIiH5Tiq
Pw2fkWOwJwM1Xs3zGQ1sxVG87EPe9Ztc2qH1XeU9AWp6FuweHfs9zH0c05Ud48mO
YzF9MQVIyhtt9m8HXHqLpE2fuAAGJtXw8M19ZaAVbLnp/TMHOoADD8hRL4gT6kVE
YRTg4DDuqj4y+8laUKQ36fWt2ZsncyfQXRKL7ZwrQuhQr9fRV9ssgjFCM46pPr43
Tih/4OTood8SCBwtcjZOb9M6tbnHfZ2K54KC9WTrtWAK61o9huofHvVay4PnTpcR
pixJcO7z/Ou+TGtQjsteB/n/YThqVTFYSMdG4OosBOdDkVRN0nDAgmOio615Sia3
MtsozNyIqU6JeBR7Beh5
=RYIg
-----END PGP SIGNATURE-----

--=-SPwVTu4AvUcvAusFtjU1--
