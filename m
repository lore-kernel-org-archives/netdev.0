From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] i40e: fix passing wrong error code to i40e_open()
Date: Wed, 30 Apr 2014 23:28:38 -0700
Message-ID: <1398925718.2395.14.camel@jtkirshe-mobl>
References: <1398916513-1573-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v78OglmYrfCvkZ0Zwx3L"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Elizabeth Kappler <elizabeth.m.kappler@intel.com>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbaEAG3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 02:29:09 -0400
In-Reply-To: <1398916513-1573-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v78OglmYrfCvkZ0Zwx3L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-30 at 21:55 -0600, Jean Sacren wrote:
> The commit 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(),
> adding i40e_vsi_open()") introduced a new function i40e_vsi_open()
> with the regression by a typo. Due to the commit, the wrong error
> code would be passed to i40e_open(). Fix this error in
> i40e_vsi_open() by turning the macro into a negative value so that
> i40e_open() could return the pertinent error code correctly.
>=20
> Fixes: 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(), adding
> i40e_vsi_open()")
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Elizabeth Kappler <elizabeth.m.kappler@intel.com>
> ---
> 3.14 appears to be affected. Petition for -stable.
>=20
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Jean, I have added it to my queue.

--=-v78OglmYrfCvkZ0Zwx3L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTYemWAAoJEOVv75VaS+3Oo/wP/jKS+rsmY87hKDv2ek/xIf4k
KQik2QnmNUKAWH3sAfZMxG2KO/EVX72egT3DYwhjTyNZQcl48H+Uctc6DHxENL9b
WO5qgm4Dcf6vL1Ckq5Gf1XGtc+F6MWSHghTU7FMvEWMD4h5x1VITd75G2v0zHhPf
Qzmad/OuAmUCjvuXA3it09j9NoTp9KftqfYyd6POAq/AitIA794G/kPNdOxh9SMr
Dhl6qrtGwfEKCmivt1aDUX1C0rtVhIop96T5VJ/BtCnPbDLgbhCr/IUHfVN9yBwY
Cf7rsVLbOVXeNYigIVJcNtl4nglXLWYtgPhDg0xJcalilJeNy/97//orsbuCZX2K
IkSsPOZCFaKU+FNIL56D5wk0trHnVWeUYz0VEVM2v1kTZ1WyABwOtVfQwJIPN4M8
ORDgN/P8LyX8MQkfCndqEaZd2dnQCaf5mnGd/keFqcT17q7qv1mnTnbgGMeaL2lX
zIir1FdoCbBjC8zF8A+iyBDrAhC1aofXka7ciVymoBZn4I23/nj8YLRXxtJwFXGi
/6kzDcMlsm/txZ4WdA+OYK88VHccouV+KLucGg/0/vdUBk4U3ckS8Hk4w8BRC83E
b+Gdb3CEwbkMWBO4wRJTmx8x9gV5tUQdLiPD+4Tt1k6NNL+VokYMNQwHFiQUKFXp
yfTvoAgp/sAyriYkfo0W
=n6eR
-----END PGP SIGNATURE-----

--=-v78OglmYrfCvkZ0Zwx3L--
