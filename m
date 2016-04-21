From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2] wlcore: spi: add wl18xx support
Date: Thu, 21 Apr 2016 12:11:49 +0100
Message-ID: <20160421111149.GO3217@sirena.org.uk>
References: <1463330011.BhWEcYYuGD@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
 <20160419171239.GC3217@sirena.org.uk>
 <sjdvun1fuj4nyi0bgf268g53.1461086401627@email.android.com>
 <20160419172706.GD3217@sirena.org.uk>
 <oe8hqfknrcljrjawnrxlohvr.1461087275186@email.android.com>
 <20160419175402.GE3217@sirena.org.uk>
 <us0dopt1inbrt0x47njgc2vy.1461089085965@email.android.com>
 <20160419184627.GG3217@sirena.org.uk>
 <8665E2433BC68541A24DFFCA87B70F5B360C2E14@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xdTJfaku+U7U7swX"
Cc: "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	=?utf-8?B?77+977+977+977+9IO+/ve+/ve+/ve+/ve+/vQ==?=
	<eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B360C2E14-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--xdTJfaku+U7U7swX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 21, 2016 at 11:07:37AM +0000, Reizer, Eyal wrote:

> * (i) If the transfer isn't the last one in the message, this flag is
> * used to make the chipselect briefly go inactive in the middle of the
> * message.  Toggling chipselect in this way may be needed to terminate
> * a chip command, letting a single spi_message perform all of group of
> * chip transactions together.

> Now, in my case I need the CS pin to go inactive and stay inactive during=
 the transfer=20
> of the next byte for completing the SPI init correctly (sending the extra=
 clock cycles while CS is inactive)
> If I read the above correctly, CS will only briefly go inactive but will =
when the next byte=20
> is sent it will be active again.
> What am I missing?

No, it changes the state.  The main use case is a brief bounce but
you can use it for other things.

--xdTJfaku+U7U7swX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXGLVzAAoJECTWi3JdVIfQkeUH/RBLOC8k+a4OGBOzYmJ7lVvu
7sU/PY/57UsPjArOTRDnm1aGjROe12wGh900nPut6kOx2fa8pH++o1EHQykQa4S2
xGiyz6vnxzDGMmUpep5CVOw/lUxY6vf2/n/RMcrY46zX/Yn4DXBtbIVkiCJ0Y5PB
tJ6SDX/Ot5gGmoKgYV5Uc6rrUEnn7H4TMYOpCg//F78N9cUXupXvcmeoiYVVzEPW
zc/dao8tnVqRFVmM/qoHIXt7EpjHRO2akfx27OXm+QsRZJ1pBlqosqO1BAccMSqN
AbQKlCDbJa+6BviXb6dIiUuavNH8hSXiPpmS0o3YNN55B9mDlIgN3E9wE2oZiMo=
=TiYQ
-----END PGP SIGNATURE-----

--xdTJfaku+U7U7swX--
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
