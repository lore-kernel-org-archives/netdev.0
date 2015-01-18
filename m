From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 3/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Sun, 18 Jan 2015 21:13:57 +0100
Message-ID: <54BC1405.8010207@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111201519.GC8855@linux> <20150111203612.GA8999@linux> <20150112135302.GB18351@hposo> <20150118201221.GA15143@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2THJG8wQsmqrBqauSxJwjStwnc8dx0FX9"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150118201221.GA15143@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2THJG8wQsmqrBqauSxJwjStwnc8dx0FX9
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/18/2015 09:12 PM, Ahmed S. Darwish wrote:
> Hi!
>=20
> On Mon, Jan 12, 2015 at 02:53:02PM +0100, Olivier Sobrie wrote:
>> Hello,
>>
>> On Sun, Jan 11, 2015 at 03:36:12PM -0500, Ahmed S. Darwish wrote:
>>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>
>=20
> ...
>=20
>>> @@ -98,7 +128,13 @@
>>>  #define CMD_START_CHIP_REPLY		27
>>>  #define CMD_STOP_CHIP			28
>>>  #define CMD_STOP_CHIP_REPLY		29
>>> -#define CMD_GET_CARD_INFO2		32
>>> +#define CMD_READ_CLOCK			30
>>> +#define CMD_READ_CLOCK_REPLY		31
>>
>> These two defines are not used.
>>
>=20
> They were added for completeness: the only gap in our continuous
> sequence of command IDs from 12 to 39 ;-) No big deal, to be
> removed in the next submission.
>=20
> ...
>=20
>>> +
>>> +struct kvaser_msg_tx_acknowledge_header {
>>> +	u8 channel;
>>> +	u8 tid;
>>> +};
>>
>> Is this struct really needed? Can't you simply use
>> leaf_msg_tx_acknowledge or usbcan_msg_tx_acknowledge
>> structures to read the header.
>> Same for kvaser_msg_rx_can_header.
>>
>=20
> They're added to ensure type-safety throughout the code. Basically
> they're the common part of a command that has different wire format
> between the Leaf and the USBCan, but share a common header.  Such
> notation was only added when it was strictly necessary.
>=20
> For example, there are three functions where 'rx_can_header' is
> referenced in the driver, and one function where 'tx_acknowledge_header=
'
> is referenced. Without such header structure, I'll have to sprinkle
> 3 to 4 extra blocks of:
>=20
> 	switch (dev->family) {
> 	       case KVASER_LEAF:=20
> 	       case KVASER_USBCAN:
> 	}
>=20
> which would be _really_ ugly. The *_header notation ensures that, in
> the body of each function, we're accessing the fields in a very safe
> manner.

+1 Keep it as it is.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2THJG8wQsmqrBqauSxJwjStwnc8dx0FX9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUvBQMAAoJECte4hHFiupURcgQAIAJKM8lEXer3jdplOsR9aFl
Mov6nVQigeRMridsN1Z1lncKpIt1eCzOPJNpFjqO1AYzOTZxQ+LS+NpApQmAuHVq
TNrqUPqa4RN6bnTd9+Qmdicemw+2giBCGN81hmcv98Z7oeBNKzToZ58P45jnZ2AA
1SYicVN8jHSXVNJMZ1O4Yf+QcppZh5ptrnlqHGiii2EovWHGwnj3YfqGwpj2G2wc
H05NUCJLPTEV6ErfT0/72EdKJ6qvaedzCbCI/SpbxIwv+xrXU+r078P0o5nFkZkT
kjjHvpK/P96e4sIa7uP71hdeInxuvzyeMPaI6PvslcXE3s+B7fvNNOqQ7drPndl1
q2FNHxMFp5+eBRZ3kgmu/mNk3n338hU5G561Xro3HMz5gxjih7FsKOxDTv+ill3B
rmkGL1o1cjLRlaG1bCfPFszJCIEpNvUrG+3CxgZHzNiIeLXIN7EWlw+j5xU89OEg
QZQarX0WyvLqxP0aS7WYP+gI1HSEFawuztM0ECkTkGgQqobyG+3sPNdlXx7adliy
vXS8AVZ8jh9yiNugbEmY28yIyXDSlICT/Wfu6nbwasjWR97xTQn1jgHfdbitL0Ng
1CH2qrgNOVfVDup/KmQ524JFwmdn3unxk5JW++lonKsFyUIiURiKuRkf/K9abuf/
CyVdIB2zTe9y/DiFbPJw
=LQj/
-----END PGP SIGNATURE-----

--2THJG8wQsmqrBqauSxJwjStwnc8dx0FX9--
