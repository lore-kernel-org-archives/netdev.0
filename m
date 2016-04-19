From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 18:12:39 +0100
Message-ID: <20160419171239.GC3217@sirena.org.uk>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
 <1463330011.BhWEcYYuGD@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="4cv0JMvpEKiCIDl2"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B360C0745-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--4cv0JMvpEKiCIDl2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 19, 2016 at 09:05:45AM +0000, Reizer, Eyal wrote:

> Understood. As this special CS manipulation is unique to wspi (wilink spi=
)  I think the=20
> best option is to move this gpio allocation into wlcore_spi as a new devi=
ce tree entry
> used only by this driver.

That sounds like it is going to break normal chip select operation which
doesn't seem like a good idea either.  What exactly are you trying to do
here?  If you need to send some extra bytes at the end of a transfer why
not just do that, or add an empty transfer with a delay.  It's hard to
see what more you could do with only control of the chip select...

--4cv0JMvpEKiCIDl2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXFmcGAAoJECTWi3JdVIfQV3cH/13tX6IFbyU7cJBFsp94l8u0
RZ8ygWZrra/QQMyPguVMdheFO50a6wPZL1nZ0iPa2Zp8b0RUCjCuuDxtjoJf5QD6
39GH1LuyIK122A2S1DG5aRP8HjUtrOT5s1oE8IwGSTxSow9E60bJPOHoDt23uoFi
EDa6F+MnQ0QhPSQhKdUEwVCrNCep+qEmQxOT83fei+xd3MFAFtb9vTACNaPexOO4
iRU94K2wUO1np7ug8M9Q4Sx5inkXh+Fy3Ug34x2fWG8prhqa/TDXXfu/IyfDwlpM
0UIWRQheG7zxMdGqGsXL84gI4k6mNZKn0f37vwmGV3ioan07BzSY+LkBREXpv7I=
=FdXk
-----END PGP SIGNATURE-----

--4cv0JMvpEKiCIDl2--
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
