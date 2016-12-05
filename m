From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: ethoc: Utilize of_get_mac_address()
Date: Mon, 5 Dec 2016 09:00:25 +0100
Message-ID: <20161205080025.GG18069@ulmo.ba.sec>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GUPx2O/K0ibUojHx"
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, tklauser@distanz.ch,
        davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36233 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbcLEIA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 03:00:29 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so14126427wma.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 00:00:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GUPx2O/K0ibUojHx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 04, 2016 at 12:40:29PM -0800, Florian Fainelli wrote:
> Do not open code getting the MAC address exclusively from the
> "local-mac-address" property, but instead use of_get_mac_address() which
> looks up the MAC address using the 3 typical property names.
>=20
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/ethoc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)

Acked-by: Thierry Reding <thierry.reding@gmail.com>

--GUPx2O/K0ibUojHx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCAAGBQJYRR6ZAAoJEN0jrNd/PrOhFSYP/RsQGKMX9Gpuf/rQhEewmOUz
hTHzcIvk7qiAGsZnk8ehJEZQ5vw52FrplHBg42RM1P2+m9ZRTugw1X8JCaUvUuPm
r+qoxUxB7ROBFZnlqPtbbO48UD1dRibY/MWVZp5zKNYpg3SJ35oFhUkXX+K1c5N/
KJfAs7LsJ9ol/PTXqqzmR3N4OccW3t7gsOtaA09aV69NGfW6quu6uQ0uoLsZyx9j
6MAXpp5r3hn3PtrhMpvnSOKvtxuQEkc2h1rgmHTyJ7YTmtZr7/DWbinI16E+0J37
KZaaDAZTfH3hgXisfsIpJnVvxKFZR8/Hb2sJzOCOJyCBxxe8fIgYNU5DvEISh7uy
lxqKb0Rm5khcTi8FYm2dVEIDKzcaBigbZHmfgAd/A6bzGSABW7uWz01z4tlIwz4h
fmElNgJCHB8xBqwojyLN5DLic93GzqaLmthpgno+Vm3g09EkV4kdbRW6XZvs2Q54
rz7WbZaLtuRJsb7LCAiNH0ikZEMig+LdYyaoVgjtnrzfalvcZl6eq+TAHDDxawj+
2cuyQvBNG2wuSdtahnRkkavTR1rKjrKgWoU1tMurynX4SN0ZWkwsyHJTUyhMfT/w
EDVzNM76TJyEG0z+XigHKZw73sy+LvtIC+ME70Apc+AP6ePDK6cZ+zy6gVRunWDf
QE/f0ZVfc2eBhB8C5B8H
=FHRJ
-----END PGP SIGNATURE-----

--GUPx2O/K0ibUojHx--
