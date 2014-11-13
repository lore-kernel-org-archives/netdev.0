From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2 net 2/2] fm10k: Implement ndo_gso_check()
Date: Thu, 13 Nov 2014 15:41:56 -0800
Message-ID: <1415922116.2454.34.camel@jtkirshe-mobl>
References: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
	 <1415921801-10452-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xXioHg8ZncoHGXFeolQI"
Cc: netdev@vger.kernel.org, matthew.vick@intel.com,
	linux.nics@intel.com, therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415921801-10452-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xXioHg8ZncoHGXFeolQI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 15:36 -0800, Joe Stringer wrote:
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for something that looks
> like VXLAN.
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Reuse fm10k_tx_encap_offload().
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k.h        |    1 +
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c   |    2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    8 ++++++++
>  3 files changed, 10 insertions(+), 1 deletion(-)

Same with this one as well, thanks Joe.

--=-xXioHg8ZncoHGXFeolQI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZUHEAAoJEOVv75VaS+3OOn4P/jWpwc0mqsNkg2EvzX2mOKF9
I2Hl3uHidRnCIVpA2jdkTaoNB59+ZassSuvu9xReFyRvGvSvGXQDR5R1uIg1tzaE
eB0qvUCvS/0LXkcYFyi187lHX9Wdz9pzbTFnQWYK1k4ggdUiHfJGzbIxASGnPbUw
aPI5xrn8pL4I0svCxTEgN5T0s9YS+xSdp5yiiK9SBdvVPqqVWWjUgOHhbOj70G6x
nR1SX8Rt3VTCVbR/cbzCVAeCOcLBJiTo/pFl6Lc1FbQomUORFO6WAPy6hF5Jomfh
AbEwugh3skpqO3PHgFTXR/7QqO7PTjuCXBSgK97aEc7HCygcOUSFQX/JJELKSCdR
xh5TMQAvnYrQP8NJZ7Jq8dh1aXEkfRRH7qmKVZY1vjVAILV+mPN8RobLqzz/RWyD
5XHpYQnFpiFltE6viOKcj2rCP3ISvF0zZcx1+KCggFCK129EFyToJCWPX/hePUM+
2+D+uVX0axn2xE2YPQBqJUEmmTZDe5qsaovNw/27LoA5oGm5YeRdgKiOIbltpr9t
5o1LxlbmTbPo2Yr+G3pyVmWnlR/TI1pPWIAjGplPZPZiyUVMnGC9eIpGeWwkIP3h
ckIPoOr/EAFk+zs4E9aWQY5g/ExeWXflOjGrbg+Xp2MNQW2g1Fj3D2CIQL1KuTxm
giVgkXGXDe+5Pnf+hKMC
=Kkfn
-----END PGP SIGNATURE-----

--=-xXioHg8ZncoHGXFeolQI--
