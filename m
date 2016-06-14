From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC address on RTL8153-AD
Date: Tue, 14 Jun 2016 18:47:36 +0200
Message-ID: <201606141847.36109@pali>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com> <201606141828.10969@pali> <20160614164017.GB14477@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4293973.Md3BYvXXoE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614164017.GB14477@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4293973.Md3BYvXXoE
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 14 June 2016 18:40:17 Greg KH wrote:
> On Tue, Jun 14, 2016 at 06:28:10PM +0200, Pali Roh=C3=A1r wrote:
> > On Saturday 11 June 2016 19:42:26 David Miller wrote:
> > > From: Andrew Lunn <andrew@lunn.ch>
> > > Date: Sat, 11 Jun 2016 17:39:21 +0200
> > >=20
> > > > What is still open is do we want to accept it at all? Do we
> > > > accept the concept of putting the same MAC address on multiple
> > > > interfaces at hotplug time? Do we trust BIOS vendors to not
> > > > keep changing DSDT property name, since it is not
> > > > standardised?
> > > >=20
> > > > Do we want this at all should be decided by somebody more
> > > > senior then those passing comments on the code.
> > >=20
> > > Indeed, I think the behavior of using the same MAC address on
> > > multiple interfaces if we plug several of these in at once is not
> > > good.
> > >=20
> > > We shouldn't behave this way just because the Microsoft driver
> > > does.
> >=20
> > I agree, but in some cases it is night mare for local admins when
> > booting different OS cause changing MAC address on local network.
> >=20
> > Another similar situation: Imagine that you have two USB network
> > cards and both have "burned" into their registers same MAC
> > address. If you connect both those USB network cards, linux kernel
> > bind appropriate driver which read MAC address for both those
> > cards. But those addresses are same. What will linux kernel do in
> > this case?
>=20
> If you can find such a broken USB device, try it and see :)

What do you mean by broken USB device?

You have never seen two ethernet cards with same MAC addresses? Right I=20
have not seen two USB, but there is non zero chance that could happen.=20
Specially now when more and more people starts using USB network cards.

> (hint, might be hard to find, I've never seen such a device before.)
>=20
> I don't see how that pertains to this issue, sorry, how does broken
> USB hardware compare to a working Dell device?

It is same, how to handle two network cards which tell us, that they=20
have same MAC addresses.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart4293973.Md3BYvXXoE
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAldgNSgACgkQi/DJPQPkQ1Ls0ACfVKFxPb5W0tujrX3d3i1hiUKE
+w8AoKXedylZWWzJAY97DPqgptloz3Nn
=Prv/
-----END PGP SIGNATURE-----

--nextPart4293973.Md3BYvXXoE--
