From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 04/10] ixgbe: remove redundant if clause from
 PTP work
Date: Fri, 14 Mar 2014 16:17:37 -0700
Message-ID: <1394839057.2167.90.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-5-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4dvoKf6IMY9s/Wb2tH/s"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43087 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451AbaCNXRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:17:44 -0400
In-Reply-To: <1394818481-7652-5-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4dvoKf6IMY9s/Wb2tH/s
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> ptp_tx_skb is always set before work is scheduled,
> work is cancelled before ptp_tx_skb is set to NULL.
> PTP work cannot ever see ptp_tx_skb set to NULL.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 4 ----
>  1 file changed, 4 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-4dvoKf6IMY9s/Wb2tH/s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI44RAAoJEOVv75VaS+3OD3gP+QEuE5hJOv8B17zrP+eTBPth
S4j55vHNvMNdpzoIaJN6Q80QVHE3LgBID6Yg1ZZdlvFXcci/A+s6aMz2c8UO83gQ
gmKskVilmDGYRON6LBSsC6smeAO6agJcsdlN7/zAofuCf2HTV12DJM32iwE6WIhH
bZDXUO3Oc6R56V5NSR5vKBq0c1yIsy7HUMENUYNM/8sZUqa7N2/Wx7K285QoV42Z
MjuR4YV3KmVHsNUCYtmYhdbd4potw5I2PEXiN+blYCuXQf/CZSPgDunt7bPA3mO3
fx50wGr5zW1MTzL9kZu7O/BoypQXa1cE4lDW7+zYNVoyXTjLTsp4JD0Y5yXTu/Hd
Zmen9sfWLr0V2y2aWmBkYouP38lLASWxUDI8EeUt5W+m3jaxJ7AHN+w5+it8M8XZ
1jjU3uaMggUwNoqzx4wB9ud73dGilyrTZkipUZGYGdgnFiQThMSwqceaYmdVEyGy
lpEN6hjm7Y50Bymks2+sN9PDO1bzEvmJP5pnnnG7DSpfrSwWyDZ/QcU4cE8uO7qO
S6q7+NzAL/S6xxN47fsavidi8HjHvY4Rb8Kj02eZ4dBCNoFP0uAsjVObFTchZscu
RC6QiK+lHrR/TL6hsuIft+I9QHlsLW8xdePKOWy4I4O6fHXIwMPRNqyxtu3LxOFo
v1CgXxg/4L0VX2mdflot
=5Van
-----END PGP SIGNATURE-----

--=-4dvoKf6IMY9s/Wb2tH/s--
