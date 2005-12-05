From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: NAPI support
Date: Mon, 5 Dec 2005 23:23:01 +0000
Message-ID: <20051205232301.GA4551@sirena.org.uk>
References: <20051204224734.GA12962@sirena.org.uk> <20051204231209.GA28949@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Cc: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>,
	Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964857AbVLEXXs@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20051204231209.GA28949@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 05, 2005 at 12:12:09AM +0100, Francois Romieu wrote:

> -> netif_poll_disable() may sleep while a spinlock is held.

So it can, thanks.

> Btw, the poll/close routines seem racy with each other.

I had been under the impression that the stack was supposed to make sure
that no poll() is running before the driver close() gets called?  I
could well be missing something there, though.  Indeed, now that I think
about it the calls netif_poll_disable() in suspend() ought to mean that
we don't need to look at hands_off inside poll().

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iQCVAwUBQ5TL0w2erOLNe+68AQJaEAP/UO3bW/DMlaja/hXTTaP0mfEnjJx2JB5o
wO5lIJjldC+NKiOOk/bMPmjJfh9u5rUXC/vGJiBvH1y6ton0WAWCbcdrV8XPVSYw
dRBqAetDsNJ1QpGm3FsI7K1Clz+VE9ZdnlmGMMNlifCyP6oVC9jzr9HC7hhWb7M0
HlbjZxmRNHQ=
=BEhk
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
