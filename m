From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e100: Don't enable WoL by default on Toshiba devices
Date: Thu, 15 Jan 2015 06:53:41 -0800
Message-ID: <1421333621.2632.19.camel@jtkirshe-mobl>
References: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
	 <20141112.181813.1072534293888457853.davem@davemloft.net>
	 <1415849927.2454.14.camel@jtkirshe-mobl>
	 <201501151440.32159.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AdWP2HVJX4glXsf1aK1d"
Cc: David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201501151440.32159.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AdWP2HVJX4glXsf1aK1d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-01-15 at 14:40 +0100, Ondrej Zary wrote:
> On Thursday 13 November 2014, Jeff Kirsher wrote:
> > On Wed, 2014-11-12 at 18:18 -0500, David Miller wrote:
> > > From: Ondrej Zary <linux@rainbow-software.org>
> > > Date: Wed, 12 Nov 2014 23:47:25 +0100
> > >
> > > > Enabling WoL on some Toshiba laptops (such as Portege R100)
> causes
> > > > battery drain after shutdown (WoL is active even on battery).
> These
> > > > laptops have the WoL bit set in EEPROM ID, causing e100 driver
> to
> > > > enable WoL by default.
> > > >
> > > > Check subsystem vendor ID and if it's Toshiba, don't enable WoL
> by
> > > > default from EEPROM settings.
> > > >
> > > > Fixes
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784
> > > >
> > > > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > >
> > > Jeff, are you gonna pick this up?
> >
> > Yes, sorry I did not catch it earlier.
>=20
> What happened to this patch? I don't see it in net.git or
> net-next.git=20
> (checked both davem's and jkirsher's)

Sorry, I thought I had replied with a NAK on this patch after further
review of the changes.

We don't fix BIOS issues in the driver especially regarding feature
enablement like WoL.  We would end up with dozens of these kinds of fixes
if we to allow this.

You should go back to the OEM and ask for a BIOS update to resolve this or
configure udev so that ethtool disables WoL. =20


--=-AdWP2HVJX4glXsf1aK1d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUt9R1AAoJEOVv75VaS+3OBbgP/RIs7gMxLItovRW/9TeMjfpw
tGTYTm43QaEKdorRktnF1CVbhmMog9wm0CTu8SDU1zmMF2wMw04ycZv6y4Hc4L3+
i+NuX88mtemEnASK1hyvSk/zF+ciHOLta84gRFFJnq0kdkWGB8QI60NYNyC8hPoa
8HFteSNb4Hubt0GOJBGmmllEQdVRQ/uYNjZ0wq4AEcRo/wljb7h81fA4R4mC13kV
9wjjIuIkQrtgY4HxwsoMkd/VgAAcM7CF8I5lh48AdTO7xz7IXhKmPwhMSLspBHG1
iY6ZahW1HTafo2/LZSmPVl/MV6ClCdZ4qvhl15PspYTzfRbpm0JIGdp8gId3si+Q
8TXlyGbsUnSPFZYzehQrxUBv21oELRqIYHzJQg3Sx4JrQ7ome5vcnfnrIxv9YYmI
g4GUJcapRlnCp1oUAJGgw/Kok0GXGSMcSO+9lfM6KI0GRhSEAyE5mnaDPHw/NGQ8
GiWnXgz9V8tOKW8dR3v+iPVcl1wOjbhl8buzwqrrmeL6tVdi41TywH5Xv9ze1Mxc
a5jWXS63/m7ayjdPhxkGXFLgmvsg8GqJHtt77wkzWVaCUjxGPRtoUkKxYP0DSiw3
RDk9FlEE3oiVgb9ogeNieA+FlMiNVcCTKujYp50H7bOCnn8wb2dNVisACFSVgfsw
o/z7oZiHf3AkDD7kHYKC
=y5Z8
-----END PGP SIGNATURE-----

--=-AdWP2HVJX4glXsf1aK1d--
