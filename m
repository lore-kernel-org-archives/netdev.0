From: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Sat, 12 Aug 2017 13:43:57 +0200
Message-ID: <20170812114357.v4ru75dw5hq7wemx@ninjato>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
 <20170719211515.46a1196c@windsurf>
 <1500543415.2354.37.camel@pengutronix.de>
 <20170720123640.43c2ce01@windsurf>
 <1500555312.2354.75.camel@pengutronix.de>
 <CAKdAkRTx8jd8UToz5_EgMmdW3V47i2uo++YvVB_yzytqSA=P1Q@mail.gmail.com>
 <CACRpkdaXOv7mX+b-q1K34CB5w0SWPXCKa21wHaxL7qjf91PJXQ@mail.gmail.com>
 <1500885221.2391.50.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7165033882226333407=="
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Prashant Gaikwad <pgaikwad-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
 Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, Peter Chen <Peter.Chen-3arQi8VN3Tc@public.gmane.org>,
 Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
 Rakesh Iyer <riyer-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Peter Meerwald-Stadler <pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org>,
 linux-clk <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Xinliang Liu <z.liuxinliang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
 Chanwoo Choi <cw00.choi-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
 Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
 Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Ohad Ben-Cohen <ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
 "linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Vincent Abriou <vincent.abriou-qxv4g6HH51o@public.gmane.org>,
 Bin Liu <b-liu-l0cyMroinI0@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
 USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 linux
To: Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1500885221.2391.50.camel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============7165033882226333407==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ya5itqvemst3o4e7"
Content-Disposition: inline


--ya5itqvemst3o4e7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


> Thanks for the hint and the references. It seems this turned out okay,
> but I wouldn't dare to introduce such macro horror^Wmagic.
> I'd rather have all users converted to the _exclusive/_shared function
> calls and maybe then replace the internal __reset_control_get with
> Thomas' suggestion.

I didn't follow the discussion closely. Shall I still apply the i2c
patches?


--ya5itqvemst3o4e7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEOZGx6rniZ1Gk92RdFA3kzBSgKbYFAlmO6f0ACgkQFA3kzBSg
KbYSDw//cXJWh0R/3hL6jnBlw+6I5dbp1tZ9oKChNr2r4yN5M2w5s5CTcGdaO8dM
UwF9vYlg/rs2t+2VsPDOLzYDRuZRcNuJMFCAF1mU1ZlPA6JJBLaQNVrKM1EROR67
oslTA46qVHphTZjUBbPSwe4f1Q+KKfgKqOq/16dLq5yO/ZYrPxjP/rUcurd/haYl
MIPsJ0KBqI90zV744gYGruOO8aykoeC5TmUNkQLJg9LCqhNH2qEp63PJYyBrsgeZ
dZKvcZwzqaWI9cNzqAdCD320bBfStL3sF/B4jJzHLHy2JUbFGO9yXxoKaJKr3NpN
fRhsqqCyF0mfzjxccXR22sioSllqbmy6ZnxpRnnIEi+AQHvbRxCYhy/62qRdk0X1
XApulPWKQo2cJKBeRGSmSYxL5I1wnJDlNuCEuVUyekGajocLfnEGpPFvs8EB2+tu
kHP96bLxWIA6iwwYTNwjLEabbQ+Zba8P5evWVJg8soKI2S5KHQoNjV8KWGYLP7XX
+ibLSHV1IqsBDwNzVEOLFGzrP/xsqjMWqhdcfeDELCHA4iKlS/W/eQpxDjuKBWHn
U8aM26YWAq7W/c5h6pz1my9yYNvRehpQR+lcehb69cCDsBwwBgyj2jwGcDPDsT0O
rgEaw9CJV07s0eK4D9XLOjFjhzTCUor7Ykz6zknwFYn1l8iL/ck=
=sXni
-----END PGP SIGNATURE-----

--ya5itqvemst3o4e7--


--===============7165033882226333407==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-mediatek mailing list
Linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/linux-mediatek

--===============7165033882226333407==--
