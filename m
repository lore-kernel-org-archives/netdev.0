From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH v3 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Wed, 01 Apr 2015 11:46:51 +0200
Message-ID: <551BBE8B.6060707@pengutronix.de>
References: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net> <1427867429-3909-2-git-send-email-socketcan@hartkopp.net> <551BB555.7030808@pengutronix.de> <551BBDF1.6070208@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="CNuaLsoI3pL6LRSko3HfpXEL2xnq7DS9o"
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <551BBDF1.6070208@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CNuaLsoI3pL6LRSko3HfpXEL2xnq7DS9o
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/01/2015 11:44 AM, Oliver Hartkopp wrote:
>> On 04/01/2015 07:50 AM, Oliver Hartkopp wrote:
>   >> +struct uniqframe {
>>> +	const struct sk_buff *skb;
>>> +	ktime_t tstamp;
>>> +};
>>
>> Nitpick: as ktime_t is always a 64 bit value, I think putting it first=

>> might provide better alignment.
>=20
> No objections. Good idea.

Thanks.

>> No need to repost, I'll change this while applying, if you're okay wit=
h
>> this.
>=20
> I would suggest to take both patches into can-next (for 4.1).

I'll create a pull-request asap.

Marc.

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--CNuaLsoI3pL6LRSko3HfpXEL2xnq7DS9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVG76OAAoJECte4hHFiupUuA0P/A/3LLDPgMwZ/iqYAw5ts6du
zySn9nxqiHEzJLrAhDpbppa4we4ztkhtadwoOlZYyqbxC5zy7papZDmHzatiJyRL
NlRdL5dl7UChKMzV0y2wVoG3Y/CUJ8lsHlAbTW1ND7QmmfsPrxaqzEQ4TTOeEo24
SOzUoXqOnIwe3x3vEAn6lmvY4umA/7dvc7slgrHLnVlRtPOYu9gYc/DeqQg+mUva
2+sTfklb+n613eGC4aHW/eVNHGoy/xUHHfP3avm5FnmiQKaH7eW1pEI80iYtSZo5
LO0+j/KRv1F1ib14NeMyoJLsaCQhjc2gNGHer+5Uw+IdOPMronYqBrEYM67pPjCF
cNyJsAPrggKrHP//ZJL5O9Nc9D8vbqlHuRmsdPZoJWenMDT+xfYY5gcpwNX6oIk6
lUMNv6B9f+U9C47t+8CS8orlkyjpUjhAcPl++hhoDBvg2LJMdFJnIsuLQXSt5DvW
6uC9wACwRjtPEKbUdpq/p4l31lLbKTTXDoWiZZi0QNa6DBIqTWaR2XsDjTWN+Q2u
y1H25H7tbtVT0O/IOQKoviVNHIWd9KIIOW4DRVCfknLSQS9oGZzEWgI7Tr54JlTg
OsLOzidfJv8uT+9diw++XHM5hPnLQ9FMTAbnev7Cm8qg0j/8l7RYT8GZ5O17ZFio
tAU6k66QXi/+g1C9Xtz7
=89Ac
-----END PGP SIGNATURE-----

--CNuaLsoI3pL6LRSko3HfpXEL2xnq7DS9o--
