From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2] ixgbe: Re-enable relaxed ordering as part of
 init/restart sequence for non-DCA config
Date: Fri, 16 Jan 2015 06:45:58 -0800
Message-ID: <1421419558.2632.111.camel@jtkirshe-mobl>
References: <20150115010352.GK24238@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3MiGRmuaAV6qzmqb4nyP"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sparclinux@vger.kernel.org, emil.s.tantilov@intel.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150115010352.GK24238@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3MiGRmuaAV6qzmqb4nyP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-14 at 20:03 -0500, Sowmini Varadhan wrote:
> Relaxed ordering is disabled by default at driver initialization
> and re-enabled when DCA is used. The reason it is disabled  was
> due to an issue on some chipsets (see comments in
> ixgbe_update_tx_dca()).
> But when DCA is not used, RO needs to be re-enabled, else we have
> a serialization bottleneck on platforms like SPARC.
>=20
> This patch eliminates the bottleneck for ixgbe when DCA is not
> configured.
>=20
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Cc: Emil Tantilov <emil.s.tantilov@intel.com>
>=20
> ---
> v2: incoroporate comments from Emil Tantilov
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |   23
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   20
> ++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   11 +++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    1 +
>  6 files changed, 57 insertions(+), 0 deletions(-)

Thanks Sowmini, I have added your patch to my queue.

I know that Emil and others are looking into whether we can do this for
all ixgbe silicon, so we may have a follow-on patch to the work you have
done already to enable this for all devices.

--=-3MiGRmuaAV6qzmqb4nyP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUuSQmAAoJEOVv75VaS+3OhYMP/1suBFxAMFKUxRMOkNAciBTn
hiPFFmyrsvJUnG4FEaNBNcjdZr41RKFMKEjasEyVyzcihEamxTZzK7YDRx5Z2qrc
eezMzXP/73Oi4R7NiCU4ESmfX8pO8BAGg/r2SaCnLKuETcHzHFa5hPDK5mqphMAE
rI0fPCIWGkVUaoFc3r6Gb7F/EW0rRlxwCP7Yj0u7gG8nNvl9RmuHDDQR+G+WK4Je
iB4jriDmtNv4jQ2cOdBFyBWA9L8yVrNnBgKemtH8tOWcOXw5ZmxXFP5p8EaMm9yc
v5/dGGx3mdwZwfHG8FqvDwCKZqtMknozNBe0GQqUF4TIQmhuHCPf0pefh9dyhiQH
v/BLfRriik2bNO+L+gdLj8W7qRf/pX3+tDe3S44ohAonQTX1psmbK/UgczPLA5Dl
yJgLTXrLlxv26ZBhuG6iHP+za6w77lwU1UHk+NfW12Lmbc+iVaQ/RSfLXrquKbTj
i/i4o5EmPeENXG3cCGry6kLNRkuWRVslPGvi8Y9liZ4M0BKy3vsGl9l3cBpkgwJj
EGbD9uB0v57Fp5PpbyavBikT9XypzZjThH+bJJmxDeL1cm3zO9jbbJ7Bd0Lz04Kj
vCZgJl/DsS7+FwXjwFAz96u0/yB0X0xrvvgCOgssSq5KxyujzzVLVEbYteJwlyr/
QNeqnXEmvRazVDaKtUn3
=kP7P
-----END PGP SIGNATURE-----

--=-3MiGRmuaAV6qzmqb4nyP--
