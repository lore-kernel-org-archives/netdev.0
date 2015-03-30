From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 12:36:47 +0200
Message-ID: <5519273F.6080209@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <55191C57.7060906@pengutronix.de> <5519257A.2070907@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="r3heNlpVLocB11ToMmGWbxSoWpGAqhcIK"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5519257A.2070907@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--r3heNlpVLocB11ToMmGWbxSoWpGAqhcIK
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/30/2015 12:29 PM, Oliver Hartkopp wrote:
> On 30.03.2015 11:50, Marc Kleine-Budde wrote:
>=20
>>>   	can_err_mask_t err_mask;
>>> +	struct sk_buff __percpu **uniq_skb;
>>> +	ktime_t __percpu *uniq_tstamp;
>>
>> What about creating a struct to hold the ktime_t and the skb? BTW: the=

>> pointer to the skb can be marked as const.
>=20
> Don't think so.
>=20
> The pointer points to some allocated memory.

Yes, but the allocated memory points to a skb which is not modified, so
it's a:

struct sk_buff __percpu * const *uniq_skb;

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--r3heNlpVLocB11ToMmGWbxSoWpGAqhcIK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGSdGAAoJECte4hHFiupUgdEP/Al+viNN1yIbkGgwmjmz/ZYf
y+Pcqv8MiexTCHeX/caow5U7WLgGGL4jaFfts4PE5DAWJ1IoO74pfFgFXhoQ0uls
O3MIePjfyIhpLUolFeNYw5jx15/WK0o+YU3tt0r9YVwR7UC8b82Ls7kNGlKlApli
s30a/ssANxMgqWhP5akuqe5C0xBtQt5SEjW3URuEWAVTfOoaHvKgcdT6w8waOQ7R
SsyNdC7zVmint2TZAvmbb6ANt+6hG0rdGoSuRiMTk8wfmGciWFgdcKyxJramh004
xpOB4L6++7Nl6HZGFQGemwF1c2buTECDFOy3tMesObdy1YEJ3ZzP8Q6msPfWMuYU
TQt0KbNiVwR7XwAmmcyrh/XpshgJDFUr7yc4SwAK86ml8SqQne+5KxbQOf0aZ57Z
HGdulc9ABEZzSrNKBeXP4ruqDfj1jWtnPzyQXr6CBcfBDuin5eJVNNsoCvSPEInL
dYTW/LNJIAjVMdHcskzbxS0uAb7T+5Z1T2nKiKuM8ToK72UCEaBFHtH7OkMCGQda
7+I5LNeWyNIVpEKRaJsbeHofu0AKPXF01EkknFYXtbD4lzR27ouvzVPtbwv5+FJr
3QgcxmND55MeejLX32onAsL3ZCy1RFjXpXJEzN6TOdFbixRB3XD7vmD35KJc/Tw3
rG0zlL6Sqocc3MtmQb+2
=YTIg
-----END PGP SIGNATURE-----

--r3heNlpVLocB11ToMmGWbxSoWpGAqhcIK--
