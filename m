From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 4/5] fm10k/igb/ixgbe: Replace __skb_alloc_page
 with netdev_alloc_page
Date: Tue, 11 Nov 2014 00:32:32 -0800
Message-ID: <1415694752.2466.100.camel@jtkirshe-mobl>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
	 <20141110195221.16182.16080.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Pc3YuV8gOm+2Dko6sNMn"
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18335 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbaKKIdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 03:33:11 -0500
In-Reply-To: <20141110195221.16182.16080.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Pc3YuV8gOm+2Dko6sNMn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-10 at 11:52 -0800, Alexander Duyck wrote:
> The Intel drivers were pretty much just using the plain vanilla GFP
> flags
> in their calls to __skb_alloc_page so this change makes it so that
> they use
> netdev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Matthew Vick <matthew.vick@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
>  3 files changed, 3 insertions(+), 4 deletions(-)

I know that this patch is dependent upon the changes in patch 01 of the
series, so I do not want to necessarily break up the series by having
Dave wait for us to test and ACK this patch internally.  But I will add
your patch to my queue so that I can get what testing I can on these
changes.

FWIW...
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-Pc3YuV8gOm+2Dko6sNMn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUYcmgAAoJEOVv75VaS+3OzGYP/Rt9EaLbRj/uRBj/cCRCXwaA
IAsBnyNS2xzU9w/VRPyWF6zDk9jwhDo7BgI1OfoKHGXf2XHyDMYHSQsvmzFyZ2MI
aL9cdiHU8e09Yy7LyWG+uoFxJdl4N19jmdFiDvIenDKWMEwcWnQ38XlE+FVuB/sG
VvekZbWiSVZPtfRVd0SmsqKogRdedoGv+s5P90w/ZLgSwoUG+KjFlXnhmSqIxOcV
Fe11TQ5ESHL1wUc+w1xLwT+X9FfESfq3Qk25RxYpIMdQRM1Ds9vqK6S0czo7jDPw
m/rz/tB3Mj4Q6vSykHLBS0tiRUTCqRsM6oaUQ+ZGPRxBfRWIxQObs2rBuACFWFgZ
RvAay31lvLCimdHA7XUTpWm2Uf60bOs7KzJOkJxLCWDe+3if2w+CayqUB4sZjPHj
8JmG8yDCTFCwiVHLiAjMfwktqdUG96ctdt0dO0a44Ja/n5fA5XEBS5326R1wYaat
v6vGLhp6ut+WSHg2AsGqvb3wmFksUgx7jM4Y0zAhGiVSB5fsuMhPBKRlhlAb3GrT
G7KaNlcaO51BY3Tz2e08J+HvKWQMStsmDm/lsS9z1pIWFmfatyWBUmzojzTWzLTX
eXzLCccfnuEUuifW3+sT3fLHiGt2YPhew1pBTFsuDq8q0/4O6AmzkLXmwsD4FKyL
dWhsO69Fa8TK3tCHrEHa
=yylC
-----END PGP SIGNATURE-----

--=-Pc3YuV8gOm+2Dko6sNMn--
