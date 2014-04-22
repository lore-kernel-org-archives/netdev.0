From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/7] gpiolib: Support purely name based
 gpiod lookup in device trees
Date: Tue, 22 Apr 2014 17:18:40 +0200
Message-ID: <20140422151840.GH24905@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-3-git-send-email-wens@csie.org>
 <CACRpkdZ+3dnhoj1TS4KSVUP8iFHsjjwop-FG2Nf07YtH6aSO_Q@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7J16OGEJ/mt06A90"
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBLMR3KNAKGQEJIHPWGY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACRpkdZ+3dnhoj1TS4KSVUP8iFHsjjwop-FG2Nf07YtH6aSO_Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--7J16OGEJ/mt06A90
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Tue, Apr 22, 2014 at 05:00:17PM +0200, Linus Walleij wrote:
> On Tue, Apr 15, 2014 at 8:41 AM, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
>=20
> > This patch enables gpio-names based gpiod lookup in device tree usage,
> > which ignores the index passed to gpiod_get_index. If this fails, fall
> > back to the original function-index ("con_id"-gpios) based lookup schem=
e,
> > for backward compatibility and any drivers needing more than one GPIO
> > for any function.
> >
> > Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>=20
> This looks a bit scary and I cannot claim to realize the entire semantic
> effect of this patch, but if it's the way to go then OK.
> Acked-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>=20
> Shall I just apply this to the GPIO tree or are you carrying it along with
> the other stuff?

This patch has a dependency on the first patch of this serie, since it
uses a binding that was documented there.

Maybe you'll want to wait for the ACK from the DT maintainers to merge
this one.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--7J16OGEJ/mt06A90
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTVohQAAoJEBx+YmzsjxAghikP/3+d7x/cOh/rUcDI1bOWK4Fx
0XjUbtBEF2sOa19nAZHtEd+fRUa+KbhmTAUZ0OaEHsPpi6Xr/lfOTifV4yEZFSDm
Nz1PkCgNYjxm/NG2d8Q4qj46pZW6O0Qz4JjN+MvgAV0QZmEzfHS9ChQ+tytumouo
KwD+aQkmIb0BnT+76WJ53fDGgKK7Q7OfwNSf6gdhM3+1x8uRfIebW86W+rEW8CQZ
8+R/Pa5cHmJPn0gZ+Gy/zvbANgRx8/egGRc0WyVGHn9Pj4oeksxs0KccosR8njwm
/Hsqvo055C4rWxvpDexOWMEnPNi6kC30OU1RoOS1dacitiiABNV28AMqJDpwBxbd
/irRyFIuCu59Y2k837qusFhat5YvV0sDONnTq3R0FxFAM8x7gXjUiA89n3clvcE2
kcwCnePsAhkEAgXbcgDJw0x3WsuNc/2zTSedIMSttC6glOZds/t/sHlqMCixNrIs
sCYDbnRyzz+JK5N+BdBjLjheJj/HswrcSU5pIxTQyYwYxzEs+Iv/KPmTnYiHHFYx
mQffbuRiz9ar6TnkeA7WqHN/rQCuxMxbGDJlL+l+Xt2aB07ErIdnshuvIMmS7r/K
eu+Hd1EuOSTuKBmOTGHJplpSRoUnPPDyy1VjP6HgCmoXAwElWyDQmLh+2g+guCLr
4blTWUNXARWmv6zkR4si
=qTY8
-----END PGP SIGNATURE-----

--7J16OGEJ/mt06A90--
