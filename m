From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 14/17] i40e: implement ethtool RSS config
Date: Sun, 23 Nov 2014 03:53:42 +0000
Message-ID: <1416714822.7215.40.camel@decadent.org.uk>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WrN9M50n4uOZa8dEHVt8"
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45576 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752644AbaKWDxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 22:53:52 -0500
In-Reply-To: <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WrN9M50n4uOZa8dEHVt8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 21:55 -0800, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>=20
> Support ethtool methods for getting and setting the RSS look-up table.
>=20
> Change-ID: I52707fb371fc11fe9fd4c287e08542cde38f79d4
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 104 +++++++++++++++++++=
++++++
>  1 file changed, 104 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net=
/ethernet/intel/i40e/i40e_ethtool.c
> index fcd815d..f9f68ea 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -2237,6 +2237,106 @@ static int i40e_set_channels(struct net_device *d=
ev,
>  		return -EINVAL;
>  }
> =20
> +#define I40E_HLUT_ARRAY_SIZE ((I40E_PFQF_HLUT_MAX_INDEX + 1) * 4)
> +#define I40E_HKEY_ARRAY_SIZE ((I40E_PFQF_HKEY_MAX_INDEX * 1) * 4)

Same typo as in i40evf.

[...]
> +static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
> +{
> +	struct i40e_netdev_priv *np =3D netdev_priv(netdev);
> +	struct i40e_vsi *vsi =3D np->vsi;
> +	struct i40e_pf *pf =3D vsi->back;
> +	struct i40e_hw *hw =3D &pf->hw;
> +	u32 reg_val;
> +	int i, j;
> +
> +	for (i =3D 0, j =3D 0; i <=3D I40E_PFQF_HLUT_MAX_INDEX; i++) {
> +		reg_val =3D rd32(hw, I40E_PFQF_HLUT(i));
> +		indir[j++] =3D reg_val & 0xff;
> +		indir[j++] =3D (reg_val >> 8) & 0xff;
> +		indir[j++] =3D (reg_val >> 16) & 0xff;
> +		indir[j++] =3D (reg_val >> 24) & 0xff;
> +	}
[...]

Same missing condition as in i40evf.

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-WrN9M50n4uOZa8dEHVt8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFaR+e/yOyVhhEJAQqz2Q//WwsPginWlbF/3dRqX7ZF6Y/ibuu/yS/H
AYw/94ab/UHztxtOMfab5TU6jUxyz9gY0aS0gx7R0Zm25PhplpbxuA1+FFgdWS7z
iYWE+AMty69kxGzi+yTbJXbq/J8ujnG1sTUBFHtEkXpCSBYfTnVGieQ8ff6/0IpW
HtPMYLQ2kDgfN4e56Euhy8YnUaRAskVlYmb2D45a5mK9WqDLjHPjN1yU46fnNcZL
+jiF0ifVNXEBUtIgKqL0JdOsynGbgX9ZDsxu98qsvwnH8sMwBWqcRibJGb98HhaM
NQfR+OmesBCMBwRfyWTA43inG1RVIqASgtLMc1g1k7X81ZEoDNY/LboVVmxZGhCD
AbH06JJfdGnBcnWc2gsURoozmMHvwezQoLApiWSo45hulZxuKqajDSjwA3nXZ9me
TV+vsBW8Nap+BMaiiU6GzDk+/E5+CRAaLZMfjdL0b4tkKkLl6k15qFHxMSAWlQ6M
pkGw7oYbTcScud0pj18JQCOOoBuND40+4PlEQL3rzWYtVjqC3voyTB2ntMqqYLWH
sdsZet+Pj4tlNUf6eZtqfghxPm5ZsnTKMdDFsvc3UGoaxTzrNQ1tyT1+VLpHyQL7
BvkidZ/71/TiKKc/E9e3EZ/pZzRMERC0R9nKGWjIBP1yXui7BGyVwouwq8QkoGKg
hkYP+XnvJhw=
=btkn
-----END PGP SIGNATURE-----

--=-WrN9M50n4uOZa8dEHVt8--
