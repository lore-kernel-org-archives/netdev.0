From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH RESEND 1/2] ixgb:Remove reducant error path after call
 to ixgb_sw_init in the function ixgb_probe
Date: Wed, 14 Oct 2015 18:23:03 -0700
Message-ID: <1444872183.2928.6.camel@intel.com>
References: <1444863479-31570-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UVADVt71em06ns5ER4qX"
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444863479-31570-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UVADVt71em06ns5ER4qX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-10-14 at 18:57 -0400, Nicholas Krause wrote:
> This removes the reducant error path and now no longer used goto
> label  err_sw_init after the call to ixgb_probe in the function
> ixgb_sw_init after calling this function due to it always returning
> zero as it is guarantee to run successfully without any issues.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)

This driver (ixgb), as well as e100 and e1000 are in maintenance mode
which means bug fixes ONLY!

Is this patch necessary?  Answer: No
Is this a bug fix?  Answer: No
Should you have sent this patch?  See answers to previous questions.

Please ask these questions to yourself when putting together a patch
against these drivers (listed above).

With that said, dropping this series.
--=-UVADVt71em06ns5ER4qX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHv/3AAoJEOVv75VaS+3OLvoP/jwACXsPtrPVe+LyKWZ8pjc6
G8N3SqlYc4g2QoWMTCLgc7HjXdwNsYsUvkt7mDuXkmvfmuUmVpl9qQ4j+8YGMTwd
Xj6WrSpDUV9QZOs5CSbNFcyhz5VDYASn3E9fLzXwVsQquwr+gNG9VyU5ZYQZtXJJ
JpN9BiORHvSsdLFHW/XpEUVh73BO87e6mrlYSXpiYZbAJEoNKZczHcQoGvYikayx
/J3fLjRVMYh+gumvm66IYMOXiCEVNsQKu61cfmTkjb0qWaQliXUcSZRT3GnDsfez
8LI4dLn+LmQEU2sPHyR76IaYZ3VOs41eNsmHr5M8vbC+jl8liq1lt2podnMK4/+6
4Rgh2uwpkGcB7Qo6KY62nbCchEa3k331EpYN+eDkYvZO7osTr3pB05rFhFtyS2tu
TAtZ+IneN/4ubn0fSwz0XMX1VEg/zmF6kRoCjgH2HxmNzYMRqhRCzDneTFL1kCR6
adGgi40s7eiglo5UljREV/Z/Krgj+raIMLy6U448g8IUKvvNoIlm2D+eNpBLHNib
nZq3ZgZqYaJm+QWfu32Q7y7exzVRZ/4idvZWbXWCdIaE1k0mZyEJqRTYhbUVbi4Q
vk7AsvCEMFlPQa4bAheqlkEMABZmZyTnwl21vhVaky49O9zjt3kZYopdFmXUZ+Td
JaWKFmx0t5q2x+xu/mmL
=6AO9
-----END PGP SIGNATURE-----

--=-UVADVt71em06ns5ER4qX--
