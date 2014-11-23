From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 14/17] i40e: implement ethtool RSS config
Date: Sun, 23 Nov 2014 03:52:32 +0000
Message-ID: <1416714752.7215.39.camel@decadent.org.uk>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416680547.20938.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-npt9dw0JEP7y5z0sNPqc"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45570 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbaKWDwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 22:52:53 -0500
In-Reply-To: <1416680547.20938.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-npt9dw0JEP7y5z0sNPqc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 10:22 -0800, Eric Dumazet wrote:
> On Fri, 2014-11-21 at 21:55 -0800, Jeff Kirsher wrote:
[...]
> > +static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
> > +			 const u8 *key)
> > +{
> > +	struct i40e_netdev_priv *np =3D netdev_priv(netdev);
> > +	struct i40e_vsi *vsi =3D np->vsi;
> > +	struct i40e_pf *pf =3D vsi->back;
> > +	struct i40e_hw *hw =3D &pf->hw;
> > +	u32 reg_val;
> > +	int i, j;
> > +
> > +	if (indir) {
> > +		for (i =3D 0, j =3D 0; i <=3D I40E_PFQF_HLUT_MAX_INDEX; i++) {
> > +			reg_val =3D indir[j++];
>=20
> Shouldn't you check the indir[X] values are in correct range ?
>=20
> ( seems to be between 0 and [pf->rss_size_max - 1] )
[...]

The caller guarantees to do that.

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-npt9dw0JEP7y5z0sNPqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFaC+e/yOyVhhEJAQo2shAAtfFWZtPyseA5tfUSF5lApQWyHMjATlDk
b9LooIKvzedRG/eja/U81+qyLIWok9LzRFsARs489wMLdgODtknp7aq4zHO1Ura6
eLwAQoLQLmHfchGcJGjpbs/UB6bsPHdis0MIovL/WrsRprEgT4oJkGXq3OtXQbuY
lF1b1+ArPQZT3mVgv0DyAWcGJVeugS8EBFUCbQZpRHc7Qe/n9Ol6VIz4L5Euj674
rnuhLmVBzBQrzIh8vQBwGf1k2glNKZK4LoJe+zV/EustlgXSp9CHJ1cnC+FeGXB9
LipoqZjBw0MEgAPaL5HOkRtMBMDaO5bx9y7Q0rYlauyVAzICIBh3vC5ldOBkmQUi
zUrMZSg2Udao72dN362iMhjDXj7qWj+aQNFUZTBD17mLstI5Qg2h+RyYspRsfjku
daKhP6UfeWpchXw/zmNLS3E51cKr2j/LAgdb3tZ+ryu9cBjZMMkxz2CsITQ1t1uc
UwK8M7gnoFt31hq0HByZQBWvqTcjumb6JnG8lVxDUk8+v4Olp4kTX14g2OOvYa+6
upNx5bKN8FLB8y5VAAxpSTvl1LUrbv4KuhgmUL3VwxLXHMgApBEn/9SrYIRdDBjJ
6vNhFET1wEEnNUZFaMybIj1f/xq4QHW/0KFMCAWAbvPieX9+Y2zO5CamALzVfQ17
a5fZeolUyAg=
=lnlV
-----END PGP SIGNATURE-----

--=-npt9dw0JEP7y5z0sNPqc--
