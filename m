From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: NAPI support
Date: Fri, 9 Dec 2005 10:48:33 +0000
Message-ID: <20051209104832.GA3677@sirena.org.uk>
References: <20051204224734.GA12962@sirena.org.uk> <20051204231209.GA28949@electric-eye.fr.zoreil.com> <20051205232301.GA4551@sirena.org.uk> <20051206001934.GA18329@electric-eye.fr.zoreil.com> <20051206211729.GB3709@sirena.org.uk> <20051206215619.GB3425@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Cc: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>,
	Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751313AbVLIKtU@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20051206215619.GB3425@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 06, 2005 at 10:56:19PM +0100, Francois Romieu wrote:

> netif_rx_schedule_prep return netif_running(dev) &&
> dev_close              clear_bit(__LINK_STATE_START, &dev->state);

Oh, of course - thanks for bearing wth me.  Will fix that too and
resubmit.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iQCVAwUBQ5lg6w2erOLNe+68AQIFjwP/eWx8Hmf+TZDpG49Be7qOCO+5+2GNdy+q
NDG5r4NKd04teLxW1Y+coYE0ap3sByMT/nyB52jiORTKb3/0gaQb8bmkL+9WJvms
SnFfuUhGfLTeWVIWZhFewHzFnafjjHqJTsoE2ImuMaG4fSKB2K8Z/wJTmSa/0Qu1
b5PpT/ETCXo=
=+tvS
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
