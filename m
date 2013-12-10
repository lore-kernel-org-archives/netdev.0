From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 01/10] net: stmmac: Enable stmmac main clock
 when probing hardware
Date: Tue, 10 Dec 2013 21:05:29 +0100
Message-ID: <20131210200529.GD3651@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-2-git-send-email-wens@csie.org>
 <20131207103335.GL24519@lukather>
 <CAGb2v65YOSq_BMWSzSHX8w_hbo+0vwquBT2pnLuwNVZkWRfLvA@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qrgsu6vtpU/OV/zm"
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBG7KTWKQKGQEPPEQPSI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v65YOSq_BMWSzSHX8w_hbo+0vwquBT2pnLuwNVZkWRfLvA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--Qrgsu6vtpU/OV/zm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Dec 09, 2013 at 10:43:29AM +0800, Chen-Yu Tsai wrote:
> >> @@ -2759,15 +2760,18 @@ struct stmmac_priv *stmmac_dvr_probe(struct de=
vice *device,
> >>               }
> >>       }
> >>
> >> +     clk_disable_unprepare(priv->stmmac_clk);
> >> +
> >
> > Hu? Why do you disable the clock? don't you need it afterwards?
>=20
> The clock is enabled in *_open (when the network interface is used),
> and disabled in *_close.

Maybe it is the real issue then.

Why don't you move the clk_disable to _remove then?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--Qrgsu6vtpU/OV/zm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSp3QJAAoJEBx+YmzsjxAgCBEQAKY/ZEZloHcDGaHYS0RqXDhM
GKZTcV9duag9I2sSRxbzDXeldJYIOOZ3g5lraAhhu0Qk9JEAUt4+Tw8WjHJcxNIV
shIxhRdGZW4hcoQDiYU3KIt88Bt5rvUrbz3vxWgaKKv9pjQ2b9Qz9AwnAJfosp8z
ufhZ6dqnSHzIhXUx2yyIEuaO1Rb0LKhfGUP8zzFFfKRLmED13ctCUaqc3mUo56+s
TlSQsiWwKZ19tHoGoq3T76TGGb0fiDrMvnlQM6OGmye9EufgEtQW2v6xUSMTmKWG
myOfPxRjRfH7c5nK7L5s0e7e/cZZaepISBjDABa2kXAiY7nlzlrzk4bNMM+NuS65
jugXp1UIPPXqkPUag551JsS0A6dJarplIjwLmOvq8GBK7wFpjDFuYgfivr3o7BSb
UggC9cMwoFv7YsYF4pLwkLkUTAhOsxFht6v6Tfm6Y51AjtxqYWMZr3Llve9F41l7
2hiLygT5y0JplrTmgrSvMcFpOBUDCXkk7+pw5c6/WhDUcLhaNOS+8ioOyzJmW7mX
RAp7GSpkmc+wykNso5z0ACXTXftyG9EKq4sTHnsKJdqu7r1PPEyTOM+4LWMkf+QY
BuElAYHcU2sQsra91+VuQO+Ug66sHmOgCI176p5VeAHClvdw7u2F89QVa+f54Eyr
AmEl1ZSm8vUj9/XcrSK1
=784y
-----END PGP SIGNATURE-----

--Qrgsu6vtpU/OV/zm--
