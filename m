From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 09/10] i40e: never generate both software and
 hardware timestamps
Date: Fri, 14 Mar 2014 16:18:48 -0700
Message-ID: <1394839128.2167.95.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-10-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5pMibSgsjUKAdrCSLS+V"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45749 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756556AbaCNXUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:20:41 -0400
In-Reply-To: <1394818481-7652-10-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5pMibSgsjUKAdrCSLS+V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> skb_tx_timestamp() does not report software time stamp
> if SKBTX_IN_PROGRESS is set. According to timestamping.txt
> software time stamps are a fallback and should not be
> generated if hardware time stamp is provided.
>=20
> Move call to skb_tx_timestamp() after setting
> SKBTX_IN_PROGRESS.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-5pMibSgsjUKAdrCSLS+V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI45YAAoJEOVv75VaS+3OUDIP/RZbsfE+yiSJ+Lu+hu9CzfLT
r01v6UHdHWKCEbQ1NW1/yfSv24dC0LLiV5SS6oFflQK0HWsPwhh1oUbgGe6/s+mH
ak13ArvhIBFs/IYDli6UgP1kYCrZroSjslRsj3gYBJhFQ+EugZ7yZc42taZMR5GH
wL/8bO4Bw8chtmsmfjoK2fSv3UTV4CtqSYkA/Eg6D9wCjX6qWQSg1KJuwZnF8dzs
bfHSipjDvhYV9PFjAeX+J8bbzDmtFrk0pEpZ2DmkGuiDNzLLt0FyFF2S4hYJ3a7U
2wvdJe0TrLlEg+PPtPZx7U02HwM5w5++O+T3YAfGlbEg2g8S7sR7lTFw6yklRR50
g1ycV4GBxhHHR8W7hYvdK/dIrs37DlfY/HHLzQo5dKm4Jl69gCXtwAKZM2X1lJ64
FuebiTwArLacoUtTRn9IEnREFNxftf1vitCG/ajxAOl+XaVg2I1NZNUFsdVznfMN
u9IjWaj6TO1uh0vmBmzsup3pTT4jAUoa7Cd4NiMkjAwdh/zdmCWTKqiU2JKOmO//
+rag15pa9OpTMGCMiNhMbQuDr8yIVhfSLrQRBBkdNu0Sjt09JT/mksB/TXzDAwm8
jadPDF0kvySqwV3RsyJiYs3hx1sfn4DvKO+F1e2YLH+cZzxlUY8zv9viH5yZ4BVd
WVs1d9tGkHpbUE8dJB4g
=FEWS
-----END PGP SIGNATURE-----

--=-5pMibSgsjUKAdrCSLS+V--
