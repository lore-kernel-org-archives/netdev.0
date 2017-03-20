From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net-next] net: ethoc: Use ether_addr_copy()
Date: Mon, 20 Mar 2017 12:16:15 +0100
Message-ID: <20170320111615.GB20431@ulmo.ba.sec>
References: <20170317105215.2148-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="hQiwHBbRI9kgIhsi"
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36679 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753422AbdCTLQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 07:16:20 -0400
Received: by mail-wm0-f65.google.com with SMTP id x124so13825990wmf.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 04:16:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170317105215.2148-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 17, 2017 at 11:52:15AM +0100, Tobias Klauser wrote:
> Use ether_addr_copy() instead of memcpy() to set netdev->dev_addr (which
> is 2-byte aligned).
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/ethoc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Reviewed-by: Thierry Reding <thierry.reding@gmail.com>

--hQiwHBbRI9kgIhsi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljPuf8ACgkQ3SOs138+
s6EwhA//SEbttvgc/oYVyGU5pY1mbhiLi6HbzWhWSX+FfDo06irLlLMyFCLc+bli
CGa1iWp+ufecqyFWUA77YOUDAwn9BkVry/O5Xxd2qm5sSKiU9E4aKOncaCBKrFZ3
KXbYzgncfBbhRH+cbK4i8uybMnOL14HC1sc/lsLSC87JjP3Hs+D+x4x7ni3Fkp0g
C6+k7OeaRimKw9pDiPQIB8dkz3uZUkita26lHmqvu8yl6eFX233oms5CUNa7dOLz
KumXr55dRpeG1Yhv/i2jnJ2q89sRUqzGrlVlaOo9noUzH11iN7liajdMzW3jn0TE
00LlhS9eE8eyYZeqPY7QZQERH3s9TqyIcLfompQZCDXRlelDTNVXAchXeHh5nAcR
ByutUx99K+rKkFVbPUO69RY8E7Zf5LqWjWTVj/cgVZeUHGlU2+/RUqeYU1cGj94j
RRlmZ6ZhPt30rIjd2VuMoNwW4i65k0LhdSOqoUWygtZc6FyJTfcZ4q38OcalRKst
OA4tV9hIscOA2DVW1dxXMqiWyTthXeGHexK23eh4sQtWWqDuaob8cYYoaom/7va8
scHRYdb2TdXdYSOqSDWR7hH6bWu9Lv+wKqdYzhhvhZnmYjpnQXWXVRSIBJrXr3up
3uTNewh8Lw539A1IKJ3yCY7DHaBbiKZZLwLrw8JSs8G9vn3am4k=
=eE6P
-----END PGP SIGNATURE-----

--hQiwHBbRI9kgIhsi--
