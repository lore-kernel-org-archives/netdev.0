From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 13/15] i40e/i40evf: use logical operators, not bitwise
Date: Tue, 23 Feb 2016 20:55:02 -0800
Message-ID: <1456289702.3060.37.camel@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAKgT0Ud+SN85Pq0NokoWjA+Twr=SQDnaHvExrho1RbMUX55ttg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CCxA4PGohhJcTGrjncW3"
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50498 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757436AbcBXEzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:55:03 -0500
In-Reply-To: <CAKgT0Ud+SN85Pq0NokoWjA+Twr=SQDnaHvExrho1RbMUX55ttg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CCxA4PGohhJcTGrjncW3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-22 at 08:33 -0800, Alexander Duyck wrote:
> On Wed, Feb 17, 2016 at 7:38 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> >
> > Mr. Spock would certainly raise an eyebrow to see us using bitwise
> > operators, when we should clearly be relying on logic. Fascinating.
> >
> > Change-ID: Ie338010c016f93e9faa2002c07c90b15134b7477
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> NAK
>=20
> The bitwise operator lets us at least make a pass through all rings.
> With this new code you stop as soon as one ring has not completed
> cleaning.

I was hoping to hear from Mitch, but since I have not. =C2=A0I will send ou=
t
a revert of this patch in my next i40e/i40evf update in the next day or
so.
--=-CCxA4PGohhJcTGrjncW3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWzTemAAoJEOVv75VaS+3OTmkP/iidHDyFt5H9eV9MaxnPis40
vArI8qmtw/+pFYjte0104HfzR41mHu336oCIk9BX1Yu10Wmz51JPmLzisTyyYS3H
vkDSxwyEMRWjF7nlIHr7J2WmKcohfTbsXil059Wk7Gwn2CxTH/qZPTzbNBdcm7Q1
fCkAokD44vZ+dGLa/xLXWIdA08ROz+YhnbRGJg0nKqUMx3DCnsicW0zKT4+MBpaP
CgJYh8MHxTQnzMB7NSXi5YeH2GfcuR3eHdvnJ+Iut1gckQ/ueWhyFiRt4Za7iVMw
LzIuZ4dmbHi2VIrVDWpLRQl+LBycOce9UhTtEtb61VGw2EDadX0+QoORZwTFfEdk
mrdJpvVG0qjYbENKkkTCN0A3bd9HRGi4v3e2gSmQcIXt5br8Gcep+pxiY7Gb/RvI
X8r4lS+66L8SsD9i/cuvFC8YggOvo6xe9SQ23Zv0iwuof4cKEy1SEPxr/qBQPqDA
gL15q8UlNarGjYv4/eoqtoOtwfGEEWznTgUkUUCCNvF/2FgqpjdudyGjM2ZFQpy1
yeoZkJ3e4OGZwO3LI3LD40UwpmqYrrnzNGsFF4iYdOD/eSTBCeIHI/ddEg9GxoI1
75YrhU+28/ap+tFABqoWEURFglQJowc8MJBMzJrRZQsYt/OYG145P0NXTFQbDm++
dHJIWaJTTHjM3r9pgw5u
=FMG6
-----END PGP SIGNATURE-----

--=-CCxA4PGohhJcTGrjncW3--
