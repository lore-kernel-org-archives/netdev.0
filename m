From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e100:  Fix rx-over-length statistics.
Date: Thu, 16 Feb 2012 16:08:47 -0800
Message-ID: <1329437327.2869.23.camel@jtkirshe-mobl>
References: <1329418504-31616-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ukuekcHNC2IDVv8AKxem"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24204 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512Ab2BQAIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 19:08:49 -0500
In-Reply-To: <1329418504-31616-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ukuekcHNC2IDVv8AKxem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-16 at 10:55 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> The old code would +=3D the total errors every time
> stats were gathered.  Instead, keep a count of short-pkt
> and long-pkt counters and then simply add them together
> for the rx-over-length stat.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 4d8a616... db20a36...
> M  drivers/net/ethernet/intel/e100.c
>  drivers/net/ethernet/intel/e100.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)=20

Thanks Ben, it has been added to my queue.

--=-ukuekcHNC2IDVv8AKxem
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPPZqPAAoJEOVv75VaS+3ObNMQAII1CY44hKzpb29Ydu3s8Mka
8hsleMfMkHkBlixkxjZrOvAC4RBuXwAo2k357mdYRu9jBz++QqlrYJuVPBLVXzZr
DJnIi864USQDVjSqtAtpt1NC0eK5aipX0biK2f5Jew46i0QKbq/ilV1GuVMrmAxM
wV+QQy3ZNOmuePu97mdF7dhweu14XGr+d8kdYdnoxlqf2qPCrdmKXDaHrcqqnL2V
9GjXlqiHn3hCpGfOyPm0SSSOUBlRPoGA15a/0thXMiSrzqaWvNCODqXpImmubRU2
3iOKqgcVcOh7L39hud4bOJJhKGr9eL/Ts7ko1PDrx1QaQbEs1aWCd6zvpdmrpvj4
Rh6+fCVkkdT97xKWVegxs3f+49leXXmpbce3vIqWjSD08o680zraRAw2dPP0Gzjg
L7Gc8YpuhM0MutYKhAJde8JHjbWIApuJvg297C76OwrEK9cjJw7qqxR2ETwWcSHK
f1CgciUKgohbTxo1HRixAMdO24q69mLI4J1yOPQVTTWlDcPlpNYIBp1tkKdQh2qU
jbpU8e5S4MBTa87WCw9wqoP1EH+82uQ6TCkPZ3DcMiRPSrutbgbkY+ZyQ+MGf1aH
JCgWc2tEyvCO57K9X0UzFrC+e1Y+We+s1tl4U/Cm7q0hqOq9JT2N29GXVm5KErMN
LQAzqeG6OiA7RbcIfO3J
=uirW
-----END PGP SIGNATURE-----

--=-ukuekcHNC2IDVv8AKxem--
