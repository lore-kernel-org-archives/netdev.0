From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Wed, 03 Nov 2010 23:45:57 +1100
Message-ID: <1288788357.989.77.camel@concordia>
References: <20101025111235.GA2024@emulex.com>
	 <20101025.120943.189699949.davem@davemloft.net>
	 <20101025223853.GD15074@solarflare.com>
	 <20101025.162535.226782713.davem@davemloft.net>
	 <1288075928.6578.185.camel@concordia>
	 <20101030232155.GA14129@parisc-linux.org>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-WpnQ/lLLGQteS2F/RCV2"
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101030232155.GA14129@parisc-linux.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WpnQ/lLLGQteS2F/RCV2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 17:21 -0600, Matthew Wilcox wrote:
> On Tue, Oct 26, 2010 at 05:52:08PM +1100, Michael Ellerman wrote:
> > That horse has really really bolted, it's gawn.
> >=20
> > I count 26 drivers with "disable MSI/X" parameters. Some even have more
> > than one.
>=20
> That's 26 patches someone needs to write, then.  You can put my Acked-by
> on all of them.

Bah, come on it's hardly the most horrendous sin committed by driver
writers. And removing them risks breaking someone's system, even if they
are clueless, should RTFM etc.

> > I agree it's a mess for users, but it's probably preferable to a
> > non-working driver.
>=20
> What more drivers need is an automatic detection of a non-working
> interrupt situation, great big warning messages, and fallback to an
> alternate interrupt mechanism.  Doing it for one driver, then generalisin=
g
> as much of it into the core as possible would be nice.

More detection would be good.

I don't see much potential for generalising it though. Looking at e1000e
and tg3 there is really not much in common except the very basic idea.

cheers



--=-WpnQ/lLLGQteS2F/RCV2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzRWYUACgkQdSjSd0sB4dKhogCfeV7Vbb5HUtkxqkcSP5JTpQtu
A3kAoLgpcmpukjiny9TQQYTMMPzMI9D3
=h3jr
-----END PGP SIGNATURE-----

--=-WpnQ/lLLGQteS2F/RCV2--
