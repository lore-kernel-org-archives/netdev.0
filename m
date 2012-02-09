From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 3/8] ixgbe: fix vf lookup
Date: Thu, 09 Feb 2012 01:06:15 -0800
Message-ID: <1328778375.6576.3.camel@jtkirshe-mobl>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328693798-27323-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120208.183314.265645315647132912.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SHnJ5+x4bp7o6vc5HMDt"
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32531 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268Ab2BIJG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:06:27 -0500
In-Reply-To: <20120208.183314.265645315647132912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SHnJ5+x4bp7o6vc5HMDt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-02-08 at 18:33 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed,  8 Feb 2012 01:36:33 -0800
>=20
> > -             if (pvfdev->devfn =3D=3D vf_devfn)
> > +             if (pvfdev->devfn =3D=3D vf_devfn &&
> > +                             (pvfdev->bus->number >=3D
> pdev->bus->number))
>=20
> Come on.... do you look at these patches at all?
>=20
> I don't think you did, because this kind of code formatting stuff
> sticks out like a sore thumb.=20

Your right, I over-looked this, and it is especially bad since I caught
the problem with the igb patch (which was right before this one).  I
remember thinking that I need to make sure the ixgbe patch did not have
the same formatting issue.  But completely forgot before I applied the
patch.


--=-SHnJ5+x4bp7o6vc5HMDt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPM4yHAAoJEOVv75VaS+3O3LYP/jXfOYQZQmcNtspa2IrUNkZd
RyjFcxjOftWx57a1bIKe4ruwzjyQTDt2wRRvCJrVHkHtO31FCkuse40yL1aeaRUf
aoGuImyw1yaW9d9/KLiVW4XvtVPzbPpERXKr+MG0QYzZPvj2kyWcAPxEgIl+TcXE
cYCLod0g0AaoiH3ZzqgZgPuyb36ODKf3jjpfJXsP39mCT0Jrtw0cfCc/3tGz/omV
7zxtG/rmm6qfrk/ALgyg2+L4e87wKZLKTS7bugQoiomNStJFww2KRNsagZUJ56Pj
c5Cwgt5OgYRaCb2/V0JJzQgkTDclDYPdwf1FYmfF5QZGB+Ed4Cp1t0EiLSfdKtUG
Vs/0DmFfF5VbU5wNDzwQQvef4OH/+PrZgmSdoNk+BW0nqsMRAXuNRBG2uYPB2tMX
Vm7vnCDu8Ajw/HInn/mUe/PyclX9BmNSlKkIKZT8p3ooVxUDPFu/fANk6/c7rKat
0WLnYT50srSZfvLEk1/5k7+Ql3iZw9rQ+NZw0PZmJMwXKqe/5YozEdQL2beAF+V4
mcv3F81SP5kB0RwidSa4oWiRfIiF8s2tSi2K0cb4CAR7hy8R3IylAthtJBnQ6Ac6
NsolBGHPylj8CAvULBc3n7WcxJYAEmDnKW2gmxvSDRaJ/DH2jwQSd2/u9hMcm9yu
vdi9GVZbxL7eYJpwG/Qs
=U4i7
-----END PGP SIGNATURE-----

--=-SHnJ5+x4bp7o6vc5HMDt--
