From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] [PATCH 03/12] batman-adv: add UNICAST_4ADDR packet type
Date: Wed, 07 Nov 2012 20:17:08 +0100
Message-ID: <1403033.aGBWZgaJ6z@sven-desktop.home.narfation.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org> <1352315502-20324-4-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2955775.Cma9ToWc4s"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: Antonio Quartulli <ordex@autistici.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:54878 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab2KGTRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 14:17:11 -0500
In-Reply-To: <1352315502-20324-4-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2955775.Cma9ToWc4s
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Wednesday 07 November 2012 20:11:33 Antonio Quartulli wrote:
> +/**
> + * struct batadv_unicast_4addr_packet - extended unicast packet
> + * @u: common unicast packet header
> + * @src: address of the source
> + * @subtype: packet subtype
> + */
> +struct batadv_unicast_4addr_packet {
> +       struct batadv_unicast_packet u;
> +       uint8_t src[ETH_ALEN];
> +       uint8_t subtype;
> +       uint8_t reserved;
> +       /* "4 bytes boundary + 2 bytes" long to make the payload after the
> +        * following ethernet header again 4 bytes boundary aligned
> +        */
> +};

This doesn't work as you think. Now you have 2 extra padding bytes at the end 
of the batadv_unicast_4addr_packet and therefore make the payload (IPv4 
header..) after the following ethernet header again wrongly aligned.

Kind regards,
	Sven
--nextPart2955775.Cma9ToWc4s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQmrO0AAoJEF2HCgfBJntG4MkQALhMzDQi+skMtKKX5xovkX53
61eeGZzwDUzhiV6z4YIsCVErZDb9kvTUYHD7hbeFHJcwCcGTIKBONH1IOetlD+cs
aM+fGA067U+x62V1V1TGMwz+mJ/wHFEnj4EGlAS9Xm5D2e22Wo1v1LlCaKCtS6Bp
CMEPOljXIMIs/dFfYK+DgV0U96eAA1ZyerkU8zlTgFqEetP2P1GhLUOh3F7ZFNmn
XRM+eJULUv+uQQm3UsbIglW0pg+5Ir/znjPebRI4G76NM6p/Qj2EbL+FLLfRjysN
L8eY2ExCsvXql0ipbILUTZLyiaS1q/wUksaJLTe2xe4jsaYGjoDqdFb2xq65L6ng
Cj23nQXTQKJhgZv6/ZourtcMAmfJpDpmTbJOyjj2AQlemD0bW2Nhe6jG5tZIMKv1
nl5ZfXnAlRDn2WypkxPJBAghLP9vQAENieO8QqLlodUR03SjjccyvuRruRWteGYZ
DMTHORVvLgFghr0SPfS6Ibg9UZTuBKZJSNfrQ+YzGVwDAzKoWfmqvhoJYpVsSvuz
xw3Zqh4dAQRZ++yTO16lMb/CPI4RColUTEZCfdTXQYXknlU5RILWJY06n7BLW+qd
f9NQgLfh3Eyu9+hf/tB3CaOOWAXPPlA+Cd+GefBaWLNKnT1PpOrjpPUMW4i8O+9c
nDht8TrMfYwynb3030ZS
=DSr6
-----END PGP SIGNATURE-----

--nextPart2955775.Cma9ToWc4s--
