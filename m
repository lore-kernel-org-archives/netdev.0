From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Tue, 30 Sep 2014 16:49:50 +0200
Message-ID: <20140930144950.GQ1325@katana>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
 <1410273070-22485-3-git-send-email-rogerq@ti.com>
 <20140930132650.GN1325@katana>
 <542AB137.30507@ti.com>
 <20140930135226.GO1325@katana>
 <542AB6E9.9000907@ti.com>
 <20140930141909.GP1325@katana>
 <542ABC90.7010900@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ubuMVesmirrCclZT"
Cc: Roger Quadros <rogerq@ti.com>, wg@grandegger.com, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <542ABC90.7010900@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ubuMVesmirrCclZT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 30, 2014 at 04:22:08PM +0200, Marc Kleine-Budde wrote:
> On 09/30/2014 04:19 PM, Wolfram Sang wrote:
> >=20
> >> As just TI is using this out of band RAMINIT mechanism, should it be "=
ti,syscon" or just "syscon"?
> >=20
> > Yes, only TI uses this out-of-band RAMINIT (currently, at least). So, we
> > need an (optional) way to describe that. However, accessing syscon
> > registers in general is not TI specific and a generic way to do this
> > should be used. Which looks to me like the "syscon" property to allow
> > access to the register. Still, we should ask DT maintainers about it,
> > maybe they prefer a more precise property like "syscon-raminit" to allow
> > for further syscon extensions later or something...
>=20
> What do you think about putting the bit information in the
> syscon-raminit phandle as additional arguments?

Then we'd have <n> syscon phandles for <n> instances?

Also, judging from Markus patch [1] there is already some
infrastructure, namely syscon_regmap_lookup_by_phandle(). From a
glimpse, it doesn't look viable to add such a support to it.

So, I'd rather drop additional arguments.

Why would you like to have it encoded in DT?


--ubuMVesmirrCclZT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUKsMOAAoJEBQN5MwUoCm2bT0P/jniHexaSa9LFeSDDw56pR8S
d7kNj2Al3JGSDfZcbsHhAJg5OW869ykOZwxlFPhRJY9VFnaxtnItV5KU70u2soCA
p6YZSiowkCR9CQSAVIkK5+Tu8ivtlDk050RgSiOpn6JZinI6A8iOj+z44st3f6ic
UaMfQyGQOlV7YsFC72xnEpV4C+m1JQedXfyZszZ4GbTdHhOpn0ALxWU0Gv31b2CY
pul7LsKrwMgcWCVIuEIaRUS7TC+clJs1VxsoWgzFuPuwaVL4E/B9lxW5/wQ6JDzb
YAfSWqahXKrro6W3KPmKsSs1BKeagOUietAjHES07stlajchsKRPCoYQyUIN/g12
Tjve/K0xCH/9Gj5lFr2Svlcs1H6BrQ01wslvsPlb/yKjsP3GMEGrP8KvoEe54m0y
xX2sWO0MWm4lykb5QxLvtVNlWLg+frpl3EhvSlKXRMXlmxo690AoRmIYbzTznUyA
oJa4V6k0qS2vN3aSHhRcEutuDNQ27TTT65idTlqWcbtOQNbnh7x5knw1IZpRInAy
nWPrqWtMoEOaUZAelEmTbk1fF/QJMNYDsCekYF+IBytnqwfW5IzOM6p5+ARye4EX
9u451lWrH61MYelQq1IQcppbuc3OC2uquEvw2JlM0QnB+1L4AGaeDa1Vt8X9kQGz
uAaZHZkUezlvazsbxBBJ
=43Gq
-----END PGP SIGNATURE-----

--ubuMVesmirrCclZT--
