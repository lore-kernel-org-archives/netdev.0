From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH net 7/7] net: ethernet: stmmac: fix of-node and
 fixed-link-phydev leaks
Date: Wed, 30 Nov 2016 15:39:41 +0100
Message-ID: <20161130143941.ig2y2uh7bfhuw6qv@lukather>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
 <1480516195-27696-8-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="i3kquzqv2rvofjx5"
Cc: "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:58962 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757200AbcK3Ojo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:39:44 -0500
Content-Disposition: inline
In-Reply-To: <1480516195-27696-8-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--i3kquzqv2rvofjx5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 30, 2016 at 03:29:55PM +0100, Johan Hovold wrote:
> Make sure to deregister and free any fixed-link phy registered during
> probe on probe errors and on driver unbind by adding a new glue helper
> function.
>=20
> Drop the of-node reference taken in the same path also on late probe
> errors (and not just on driver unbind) by moving the put from
> stmmac_dvr_remove() to the new helper.
>=20
> Fixes: 277323814e49 ("stmmac: add fixed-link device-tree support")
> Fixes: 4613b279bee7 ("ethernet: stmicro: stmmac: add missing of_node_put
> after calling of_parse_phandle")
> Signed-off-by: Johan Hovold <johan@kernel.org>

For the sunxi part,
Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--i3kquzqv2rvofjx5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYPuSnAAoJEBx+YmzsjxAgLjEQALyY0pGZHdA+9U7PIG+EPbpx
5sj/6teqDOAZnriLAPH8qumZCB1g3jrwyqiJJ/aI0RbJxg3DSYFZ1Nr+iLlTF2ag
/4E1i/a9I9AL8iu+aVECpjIHLK6pp6QRIDl9w601gMO+Lyn/XTds5LbYmT51W/pW
MIc0SpuvfnEoRyyrtYHkprm3W2wNd9x+zMu2lv41ClFg8hH1VphoDgM0DAOSdeqB
507g/Cz0JXR7yTElJjxncbIHbcsIY4o7YRbAyes5FEYPKXx4xCaHTHsm5X3C7j6s
UZ9p/AoWBLZmQG1f1a76wm4HpYhUbG+3fNK8sYlEk3AvfzRENnydKCjYjhwFwb9D
rChDwh6iqEYd/4PO1adofcFQF3VEOnQAGUA1CFn4d65w9PH8ZdnD3vshOH4ixb1o
r184fYj2vTINcEqlRKsYrnNf7hTWWjBKP7uZtIAl2OKiId+WDuPVn5P3a20vbtpa
tiM/7L+wcPv02iMINrud2XDuBbwoUberNhV541noFANox3RZqm46hISY+fe6PlEo
NCDxLKxqVSP1pryswTk5H6UlSuqPxr40JqtmZ8HKYiXzrMki9PPOiLSZnu1KaR7q
EsKttO24gS8uc0uUpL0NuDeJp1wuiC4/ydMiwF4/KYEsU0TqZ+gA0uAwonzDIwsr
LdVseoFPhIhixIoyiFej
=FAZX
-----END PGP SIGNATURE-----

--i3kquzqv2rvofjx5--
