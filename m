From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Wed, 23 Sep 2009 08:57:16 +0200
Message-ID: <1253689036.4458.22.camel@johannes.local>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-QOrqA6HZ2pjIwjLS4T/z"
Cc: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org, yi.zhu@intel.com,
	inaky.perez-gonzalez@intel.com, cindy.h.kao@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: Tomas Winkler <tomas.winkler@intel.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QOrqA6HZ2pjIwjLS4T/z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-09-23 at 02:38 +0300, Tomas Winkler wrote:

> +config IWMC3200TOP
> +        tristate "Intel Wireless MultiCom Top Driver"
> +        depends on MMC && EXPERIMENTAL
> +        select FW_LOADER
> +	---help---
> +	  Intel Wireless MultiCom 3200 Top driver is responsible for
> +	  for firmware load and enabled coms enumeration

This seems like the wrong approach to me.

To me, it seems like you have a device that contains an internal bus and
allows bus enumeration. Typically, we would surface that bus in the
driver/device model and allow sub-drivers to bind to that by way of
exposing the internal bus, like e.g. drivers/ssb/.

johannes

--=-QOrqA6HZ2pjIwjLS4T/z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKucbJAAoJEODzc/N7+QmaelEQAMuftmP3njsTuM/mtq68FGQj
Sk7mQOUZbvAb4U6AHWt49q19fcSObKe8EEqjvM8MKDcbC6s5swe0raWK7x3945vb
K0vPBZpujxocxTGUiUXcXguDz7X7mClqZKoxK6ObjDIGmGh9a0Szh2g0WB+s8ERm
WHKk1g6IbwMX/8hJSDYXh/VJhFgZ/Y/duSOgg4zORu783plrAnTc06iCkCiagjgS
tGqenjs5CpcfJkeIHfMaMZrYU7uFwj9oNl7IY8Jt9l7c5hE7i7h8h7nkDu0lveio
t2CxZA+8hBaR8k0+6kJx9Z1vczHd/41BVwLHPIVWAyZtigkVVRkBod9PrQNOr0MP
ViL0c1yhJMvEAFVd7BhXGUAR8ShWvTFeOmEtg7BjlTO17b7IcPJsAKjjlVmkcBtF
9tFAFrVRdlOZudt221wqjXh17eCZP1lkzUHZ92RFou3Vu9Ch/hdWGgIr6nZg9gCU
8Kpawffu1KtHjEs08Qj5YZSYeF82NrdQOkhcrn0utgp9wEA8fUIavKseP3+1tdVr
rpBas73OYEE4EUcQy4I/PJEYlsTTnQxt8SrGGiMjxDapt+NvFfIQp4D5BHKmyJcg
EOsB2ON65qS9YT7T5yGlZX7cldvkB8N7kYrWXZncNuh4AZnvwiU047fw9umHajTf
xwOOu3FlJb4cLk1laQtv
=VcP6
-----END PGP SIGNATURE-----

--=-QOrqA6HZ2pjIwjLS4T/z--

