From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: Fix incorrect pf->flags
Date: Thu, 25 May 2017 02:13:44 -0700
Message-ID: <1495703624.49259.39.camel@intel.com>
References: <1495242112-14835-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-HLG64JqF4O+L1u6JPD2m"
To: Tushar Dave <tushar.n.dave@oracle.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44268 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942139AbdEYJN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 05:13:56 -0400
In-Reply-To: <1495242112-14835-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HLG64JqF4O+L1u6JPD2m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-05-19 at 18:01 -0700, Tushar Dave wrote:
> Fix bug introduced by 'commit 47994c119a36e ("i40e: remove
> hw_disabled_flags in favor of using separate flag bits")' that
> mistakenly wipes out pf->flags.
>=20
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

:-(
Not even close to applying, I even tried to apply by hand but the patch
was not near the same as my branch in my tree.  I will forgive this
second instance of a patch generated on different tree/branch, but I
really must insist that you use my tree & branch if you need/want to
make changes to Intel wired LAN driver changes.

>=20
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index d5c9c9e..6b98d34 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -8821,9 +8821,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
>  		    (pf->hw.aq.api_min_ver > 4))) {
>  		/* Supported in FW API version higher than 1.4 */
>  		pf->flags |=3D I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
> -		pf->flags =3D I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> +		pf->flags |=3D I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>  	} else {
> -		pf->flags =3D I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> +		pf->flags |=3D I40E_FLAG_HW_ATR_EVICT_CAPABLE;
>  	}
> =20
>  	pf->eeprom_version =3D 0xDEAD;

--=-HLG64JqF4O+L1u6JPD2m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlkmoEgACgkQ5W/vlVpL
7c7JsxAAhXFAJfkgsLbRx0Qx4bC6ZD/3YEaFObGRVYeQlIhiQnN2jjKa9snSL6W4
do1suhcsZbpcd05DkYcjM7JuhlRvQxlDFpuaEfGV8ywmouMqAURJnoGNpFGIjV3u
5F6JDBouWdsoiHyQ1nYyJyKwfPw6wnJKyBqmjiDO8sbeZUaob7/L21wneAS67iOu
mGuYshC+te9mGAsRZdzQsaf1J1zUSN+ERdV3biK+XYYqVHZE0ngXEkv7ZHbAFl50
0frl6QauKU8D+dSD3yffq/DMKFw5GE4w9WGz4DSuCHzdHMQdEINSirKWU804ZtrJ
kdaJNeFsI4MrV3JXbuvBaOkOM+tGkMv9QN1yw88n1esi6Nzxqm6z8faldeg9f8+4
h7V3Dis53R2DuVKagxECPwNzo1a5CcV0z4nLDEw6n7NDsF6aKhysMqb2/RlShubN
DguMkrYaQYBIdngOhzi52ZE+k4TuZosisYEK3maJ6tsRMS4YBogNV9/Ky6L0F55P
R0it8OCAyFtDuaxyX1vuwUWWtBvKVchGIwtAFl7UhSXZH3B0G5EUY/ctAxb6YMYt
4geL6mRsQCBJxZXxUYry33fmpLHSHrXaBtZuQ1KEaL7NsKZPLPJ7RDBfITuUBATo
zQQBqSipY6Bq7P3we3LuOOec4k0WcAds0ojzmNpgtW5SkWCIIm8=
=0411
-----END PGP SIGNATURE-----

--=-HLG64JqF4O+L1u6JPD2m--
