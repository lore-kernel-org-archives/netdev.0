From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Move e1000e_disable_aspm_locked() inside
 CONFIG_PM
Date: Wed, 15 Jul 2015 03:30:16 -0700
Message-ID: <1436956216.13597.8.camel@intel.com>
References: <1436846075-29366-1-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VTmvpgczFj7nlI2vzPPt"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, aaron.f.brown@intel.com,
	yanirx.lubetkin@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Michael Ellerman <mpe@ellerman.id.au>,
	"Avargil, Raanan" <raanan.avargil@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436846075-29366-1-git-send-email-mpe@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VTmvpgczFj7nlI2vzPPt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-07-14 at 13:54 +1000, Michael Ellerman wrote:
> e1000e_disable_aspm_locked() is only used in __e1000_resume() which is
> inside CONFIG_PM. So when CONFIG_PM=3Dn we get a "defined but not used"
> warning for e1000e_disable_aspm_locked().
>=20
> Move it inside the existing CONFIG_PM block to avoid the warning.
>=20
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

NACK, this is already fixed in my next-queue tree.  Raanan submitted a
patch back on July 6th to resolve this issue, see commit id
a75787d2246a93d256061db602f252703559af65 in my dev-queue branch of my
next-queue tree.

--=-VTmvpgczFj7nlI2vzPPt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVpjY4AAoJEOVv75VaS+3O/W8P/2uoSYqLpIaS+AcDevRk8ZGF
sXzubM8BaL6TFWTQmpNXXVXnwl0uusdUP10+p+s2ngmU/0DLNAGVo1TvkAM+MoJ0
9EasSsiNE9+WwSgUnLA8U1MdxXcMsbGA38n7QzBf8YzdVdNPmJ5owaXhO5ipjVyj
OPO25UpgoWkERGm8qWgnHIt4jrwPx0GYHU9LR2reUOZALosU4tGzQhprwSDwCmZy
m4Nf25h7w59y+PsnrYAiGN0ENsuP8sE8HtE6QekFWDfTP5YBXM43d7uxsUL3TLsl
TfwlXkaPpcAQX9bLv7hUD9vifGTY+wlVftBx8JgP5YyXX0BtGZyusD4YT4Go1lnb
iv7A7OSA1UYtGAx5trABtvzfkJSUJrgAnoVMUHMk80iqDBUuhOc1RrrNkzCBAFMx
vyE8AlZ9V+0GSjgJglYGAbmdVI4iOUu+ptDWwBNpGp8yEf+KpJjnHmKuXlmxgFeq
PnlAWm5GaD321BCLDxrMpLe/mtSyeZ8YTpVSZQHumJNMblcMDtykCM56F5ms6AhY
SLEB1rR7LXokKkqUeQfX2DxPx//kIjOZRn2IZpuzUIxLtvs1l87HQOJhmqbR+NP8
N2GinMMlzhy4KWMvwZIoiDlzZ8Ul+/OsAJty62LUNwqBVNky0CdQ3jA9T6hVYJT3
DJ4zSfWUtaBw+JI4FP14
=52GT
-----END PGP SIGNATURE-----

--=-VTmvpgczFj7nlI2vzPPt--
