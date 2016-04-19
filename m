From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 18:27:06 +0100
Message-ID: <20160419172706.GD3217@sirena.org.uk>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
 <1463330011.BhWEcYYuGD@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
 <20160419171239.GC3217@sirena.org.uk>
 <sjdvun1fuj4nyi0bgf268g53.1461086401627@email.android.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="EP2pG3U7hXy67fX3"
Cc: "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	=?utf-8?B?77+977+977+977+9IO+/ve+/ve+/ve+/ve+/vQ==?=
	<eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <sjdvun1fuj4nyi0bgf268g53.1461086401627-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--EP2pG3U7hXy67fX3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 19, 2016 at 05:21:01PM +0000, Reizer, Eyal wrote:

> The main quirk here is that i need to send extra clocks after the spi init command while the CS pin is "high" in order to put the wilink chip into SPI mode.
> So just sending an empty transfer wouldnt do the trick here.

A single byte transfer would result in extra clocks being sent so there
must be more to it than that...

> Do you have a recomendation on how to do it without changing the core logic. If it is possible it would be really great.

Please be explicit about what you're trying to do here.  I imagine you
may need to change the core logic but we need to know what it is that
the device needs.

--EP2pG3U7hXy67fX3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXFmppAAoJECTWi3JdVIfQ/oQH/j0MMWsgYKYzsuK4POtzTpyJ
lGSE/l5CDNo99oXISIKHARL8soJXUOOwUHXsVHlo5Hb8eFDrLe7c8hVfr7j7+iVx
8cH+PZZ6qxsTn7X5Lm3IjpqbiZV3aHGFMgxuCAh31++ZYYi1eS86mNqQLHxIH7Wi
iiImKWSJtBplg/9s1YHYcJtatgELI0jCsMsYjhKuMaYQrBMlKBd24dJx8UblzrSd
bLii2gUB96kitwJa7gVdEt4V3tCPg1KhcTRObkEemLZcKmI0pw4epoNt6xk/FDi7
LC2F55hrnaE9b2XUxB9PGejmD2bwasdumNB1Jy0aqEI+F/nhWgVhASSyxv7YNSc=
=ggS0
-----END PGP SIGNATURE-----

--EP2pG3U7hXy67fX3--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
