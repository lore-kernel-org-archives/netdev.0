From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/7] gpiolib: gpiolib-of: Implement device
 tree gpio-names based lookup
Date: Tue, 15 Apr 2014 16:20:24 +0200
Message-ID: <20140415142024.GD3207@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-2-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DiL7RhKs8rK9YGuF"
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBQECWWNAKGQEYFFJTYI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397544101-18135-2-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--DiL7RhKs8rK9YGuF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Chen-Yu,

On Tue, Apr 15, 2014 at 02:41:35PM +0800, Chen-Yu Tsai wrote:
> This patch provides of_get_gpiod_flags_by_name(), which looks up GPIO
> phandles by name only, through gpios/gpio-names, and not by index.

IIRC, gpios only uses the *-gpios properties, and not gpios/gpio-names
pattern seen on various other things.

Is it some new property you introduce? If so, please add it to the
documentation.

Now, I'm not sure that having two distinct representations of GPIOs in
the DT is a good thing. Yes, it's looking odd compared to other
similar bindings, but it's what we have to deal with.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--DiL7RhKs8rK9YGuF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTTUAnAAoJEBx+YmzsjxAgE10P/iXHV6FcwR6t9LG80jHi9/Mz
blvHZyxUdZFxmsdH3g8aWFJQ18vMyaMi3H2ynAWA9a5vx1jZeycmrUvpghYe97vc
QcrRcTIhlu00vPLR9bANjKFixmQ7SYMpdkIKSoMT1nDqwogcu2eixjT4VO2EXORU
mAOpqgD8wVPmvy75i++9RronnhQBrvjE7TPdeFeVCNYdL4Ddf4N9mFhmnwNc57Zp
Qd9O+5yTkDPw35UMjtNPCuvyb5BtO8o/38M1rTP+hjGEGyYT8BmTS+nZuyIpgXnc
GdYh3OvkI/8TZNUwOxs+06IjG6IeystiYGlvcVX/PRGFk5olT5dKsoPbqWicV2xd
18LdhwfIsikGfOazIzpu9yo50cX/x95R/YAjHVg/sgEU49Vj/+R4wYVLaM76ipws
0I0JCovXk0NQnPOElcelVbnMgVuf3W5/pNW1YTuxM0+4ToLrMN5R3Rc+uIzwqqed
BggdFPfwx8hgEJy9XyCU8r0fFUp0vDzTkgxBgiOKWHW/SoUicSOpGbkC3AGgk+0W
y6Qms1hlzyi5n8JoDW5N89HWhYwkGUzquoFZBI+a++lD4H5GepOl5yuVrBPbgnbk
efIKFif2xdnrSFrfU/ujwlYj+k6FNbH9F11LzZsi0bUHcBdGef6S5hVNAMzrlF/u
a/LUrtmdTYCeZLc2024f
=WQtb
-----END PGP SIGNATURE-----

--DiL7RhKs8rK9YGuF--
