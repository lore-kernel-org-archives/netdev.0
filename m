From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] e1000e: display a warning message when SmartSpeed
 works
Date: Wed, 16 Jan 2013 13:16:09 -0800
Message-ID: <1358370969.6408.11.camel@jtkirshe-mobl>
References: <50F60F18.2030108@jp.fujitsu.com> <87sj61gu6j.fsf@nemi.mork.no>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YXjNDXo8tAS+Co6MOUFH"
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	e1000-devel@lists.sourceforge.net
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27953 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332Ab3APVQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 16:16:12 -0500
In-Reply-To: <87sj61gu6j.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YXjNDXo8tAS+Co6MOUFH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-01-16 at 13:59 +0100, Bj=C3=B8rn Mork wrote:
> Koki Sanagi <sanagi.koki@jp.fujitsu.com> writes:
>=20
> > +			if (phy->speed_downgraded)
> > +				netdev_warn(netdev, "Link Speed was "
> > +					"downgraded by SmartSpeed\n");
> > +
>=20
> Could you please avoid breaking the string both here and in the igb
> patch?  This breaks the ability to grep for the warning.
>=20
> Quoting Documentation/CodingStyle, Chapter 2:
> "However, never break user-visible strings such as printk messages,
>  because that breaks the ability to grep for them."
>=20
>=20
> Bj=C3=B8rn

I have fixed both patches that are in my queue, since the original
patches generated checkpatch.pl warnings on the strings being on 2
lines.

--=-YXjNDXo8tAS+Co6MOUFH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQ9xiZAAoJEOVv75VaS+3O6EsP/1mTZNVNKmHNE0AUcoIcCayw
dKfFxs+kLhOFuOnVItizWIC4gvCNDktSd2C9xxz8O+xuOSsXdyyZ+8tvBfOs00zW
p+A9QpEIfjVny8UifndXF+gVxBOVMO4uXR8tiQtEhdBn9nggvw4qqBuqsCb6XqmD
kPI+X6OBSx7HpN8ts8rvW3xBX1xMd15GI5AYgQa9jhC4pR8gD1E+LEvqHbaXQVdE
QckmNTDWh4q4hMZsBEAqle0DSGIdTZJI6LUAUSvaT/nvGIYwJC7LAQ+lxQq7FboU
PvTORvOTGgBn8iV+6WALim+1uMKYk/WdBVV08x2S2gpm+Lg18GLHlysJ4qQ5gjOE
/QyYZdNJPkGDiHrepyUKDl63n4iDl+brCGG5VzJ6MKyqtjb27a/FW9Y6P3I5e9Cr
i7ljdHEJ5mYQfuRBqblXrKySP7+YkjSQOG7mFofabwC675fzYGl+x0jZjfUhCjWR
E0/3xwJJmVLFAZ+FienRvlZWKnEXkRlybaC1hmGR+4jpcrav98WL8B294KTT0FD6
95RSc+rrXM7D1ALHW8fsjj5ZWbmub8fGTwXpMvKwGnmJbJLP5ZwXpr2QOq7tdRmk
1ed+pcZHCe74Wy4WBFzgoGe9QQEOIzQkScbhPvmhKpiUUAPJagqW9v/3rbKSMP8y
dqhdvqdGNuIF+g0F91eZ
=M48k
-----END PGP SIGNATURE-----

--=-YXjNDXo8tAS+Co6MOUFH--
