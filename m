From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Wed, 21 Jan 2015 11:44:54 +0100
Message-ID: <54BF8326.3080406@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux> <20150120214537.GB16828@linux> <20150121103319.14511.57709@shannon>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Saaec6vgQSg9TUi22lNmbclxo2ldABKTO"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150121103319.14511.57709@shannon>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Saaec6vgQSg9TUi22lNmbclxo2ldABKTO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/21/2015 11:33 AM, Andri Yngvason wrote:
> Quoting Ahmed S. Darwish (2015-01-20 21:45:37)
>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>
>> Replace most of the can interface's state and error counters
>> handling with the new can-dev can_change_state() mechanism.
>>
>> Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
>> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>> ---
>>  drivers/net/can/usb/kvaser_usb.c | 114 +++++++++++++++++++-----------=
---------
>>  1 file changed, 55 insertions(+), 59 deletions(-)
>>
>> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kv=
aser_usb.c
>> index 971c5f9..0386d3f 100644
>> --- a/drivers/net/can/usb/kvaser_usb.c
>> +++ b/drivers/net/can/usb/kvaser_usb.c

> Looks good.

Is this an Acked-by?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Saaec6vgQSg9TUi22lNmbclxo2ldABKTO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUv4MpAAoJECte4hHFiupUxucP+wegvaIrWMypNeoTQ9/UV+ia
v/Rh4T8HLQgKIjIJwTRtcrbtt1DOCYzRAYpWyMWAm48A8zKwaIpasbiRd17nW21g
G83ICAg5J9y9ueLvAf4dSDw8sTcOcNF8/TSMZxmpgFz4YMYKuUChjFLJHS4TWgps
B7J4rG3krC31PvW1Le2KYz43wtgjeO/3PVIGSiBrvF+mvd5OUfbbzHZWZ2yEUf1G
l4F+5FxGH/slfWlC4g36wur16grTFc+ewKwEKQBgZrDXVGBqbGgzyael8q3oPwun
TRP2bjSgVviRxilSGO/AyzuSCTplQH+lkGsngnMy5yCeerMV+2Zf1TNmnKBPyYYy
CzGyFLS2QMMpkGfgt7C2NbBhww7PjMp4GRvX4ktLKedYgu7x1ypUzzoecx2/FWp5
Ul3tVw6djkSNCONHf4hBbbankALErGOKP2InZWUTjihFGGGfV3JhXzCWzt4P5v0C
Tk+XcxeOrvdalAPEENuesJg8qpCurIPt+gzw0BHh0GmiiKZX+ycKsGZ8mcZNcn5T
m5sK6V6vayfOIaW3jFG37VU7UHi7MT/Ikax62q5xewTwn0K2sLzqJ5ssxyFP5SjH
o/7yrF5q2VCtTpD+bhyL9WF030cbrgZm9v2Os19uCvQ/9UISzN3wk6vm8S94GWRS
tqwmWmWQjZ+XhHTckjQn
=C+4n
-----END PGP SIGNATURE-----

--Saaec6vgQSg9TUi22lNmbclxo2ldABKTO--
