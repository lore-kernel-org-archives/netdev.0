From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: ethoc: Account for duplex changes
Date: Mon, 5 Dec 2016 09:00:12 +0100
Message-ID: <20161205080012.GF18069@ulmo.ba.sec>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GLp9dJVi+aaipsRk"
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, tklauser@distanz.ch,
        davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34619 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbcLEIAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 03:00:15 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so14170885wme.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 00:00:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GLp9dJVi+aaipsRk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 04, 2016 at 12:40:28PM -0800, Florian Fainelli wrote:
> ethoc_mdio_poll() which is our PHYLIB adjust_link callback does nothing,
> we should at least react to duplex changes and change MODER accordingly.
> Speed changes is not a problem, since the OpenCores Ethernet core seems
> to be reacting okay without us telling it.
>=20
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/ethoc.c | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)

Acked-by: Thierry Reding <thierry.reding@gmail.com>

--GLp9dJVi+aaipsRk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCAAGBQJYRR6LAAoJEN0jrNd/PrOhlqQP/RTfadYZ/l57T0fIzgqfXBwA
h621JOqH4uwQPtV7rHtgIz3Mzgxzt7yNK1X62f33RTjuph7URJZrmtzgPYdTBize
w7J0PyI6ZUZE+04/AQba5sVMKEKZu7n+CtSj9AS2yP4qkIcSj4Hq9DEZ5OAIeUH8
m5qUVqN38I4EU/nNwgcs3gx7wM4OtDpTUYSlsgLDzNGV3bH3XJQzcAM/nAzhNnxE
Ifz58bBpTxBP2YonzEPfAePWiHIGO5ONw3runpU/oIndFtLjZmjp3BQ0Fqk2CnCZ
SebGHrnyJa57b4Bt1Ini6+9x5Pp/0iQaaf8Kbq0/K7WSJT7g9sIqvqRUVI0g3wXY
yB2kaa4yUoqou5IVKHqnxTB/Kgh36pGhxn3MvRtwPkDi+Dr4GMQNWu1ccg/yihGj
sFNuhc6FNUSPwyJp4jiKV0P/cro1MnpJrnHUoTIvPecoeZxV6Jg+Prl6tmyQnGYi
5+yJ73JmHsmXlhFsw3AmqwEyjK/5SXvjoGEveKek9kbE6bZKGs2zxK/VW/lSpFqy
WP/dmfkp4wPTO0RoQXlUUhO0ZEHoefjBXXlN+WqIXorhtDCRsEEiNOqarZxFP1ZE
4uXSEGJcaQSvIOcbtUgr9qIC1uNI6WlC0UwIoti5oOuUvky2svrLEYL0ZxscsnFS
gInre4Nu/1ZD2UytuM5+
=UgKp
-----END PGP SIGNATURE-----

--GLp9dJVi+aaipsRk--
