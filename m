From: Henrik Austad <henrik@austad.us>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Fri, 16 Dec 2016 20:07:59 +0100
Message-ID: <20161216190759.GA1163@sisyphus.home.austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
 <1481911964.3572.1.camel@gmail.com>
 <20161216.132057.1771215556712298530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Cc: gvrose8192@gmail.com, linux-kernel@vger.kernel.org,
        richardcochran@gmail.com, haustad@cisco.com,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161216.132057.1771215556712298530.davem@davemloft.net>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 16, 2016 at 01:20:57PM -0500, David Miller wrote:
> From: Greg <gvrose8192@gmail.com>
> Date: Fri, 16 Dec 2016 10:12:44 -0800
>=20
> > On Fri, 2016-12-16 at 18:59 +0100, henrik@austad.us wrote:
> >> From: Henrik Austad <haustad@cisco.com>
> >>=20
> >>=20
> >> The driver is directed via ConfigFS as we need userspace to handle
> >> stream-reservation (MSRP), discovery and enumeration (IEEE 1722.1) and
> >> whatever other management is needed. This also includes running an
> >> appropriate PTP daemon (TSN favors gPTP).
> >=20
> > I suggest using a generic netlink interface to communicate with the
> > driver to set up and/or configure your drivers.
> >=20
> > I think configfs is frowned upon for network drivers.  YMMV.
>=20
> Agreed.

Ok - thanks!

I will have look at netlink and see if I can wrap my head around it and if=
=20
I can apply it to how to bring the media-devices up once the TSN-link has=
=20
been configured.

Thanks! :)

--=20
Henrik Austad

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhUO48ACgkQ6k5VT6v45lkcewCfUyRuYP2gv4bt84NbJ+wkMlv4
iRoAn2wZQpq0Fs5q4WxR2aybsxDtGJOc
=dYRD
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--
