From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
Date: Tue, 22 Apr 2014 10:58:30 +0200
Message-ID: <53562F36.6020005@pengutronix.de>
References: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local> <53424C32.7090000@monstr.eu> <707ea084-ed82-407b-8967-1e82a994b784@AM1EHSMHS003.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9CxfKEqGoHewKFOiBSMidlRv0KJjxfEu1"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"monstr@monstr.eu" <monstr@monstr.eu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <707ea084-ed82-407b-8967-1e82a994b784@AM1EHSMHS003.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9CxfKEqGoHewKFOiBSMidlRv0KJjxfEu1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/22/2014 09:56 AM, Appana Durga Kedareswara Rao wrote:
> Hi Marc,
>=20
>> -----Original Message-----
>> From: Michal Simek [mailto:monstr@monstr.eu]
>> Sent: Monday, April 07, 2014 12:27 PM
>> To: Appana Durga Kedareswara Rao
>> Cc: wg@grandegger.com; mkl@pengutronix.de; Michal Simek;
>> grant.likely@linaro.org; robh+dt@kernel.org; linux-can@vger.kernel.org=
;
>> netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
>> kernel@vger.kernel.org; devicetree@vger.kernel.org; Appana Durga
>> Kedareswara Rao
>> Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
>>
>> On 04/02/2014 03:13 PM, Kedareswara rao Appana wrote:
>>> This patch adds xilinx CAN controller support.
>>> This driver supports both ZYNQ CANPS and Soft IP AXI CAN controller.
>>>
>>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>>> ---
>>> Changes for v7:
>>> - Updated the driver with review comments.
>>> - Moved the driver bindings doc as a separte patch.
>>> Changes for v6:
>>> - Updated the driver with review comments.
>>> - Used the clock names specified in the data sheet.
>>> - Updated the devicetree bindings doc as per Rob suggestion.
>>> Changes for v5:
>>> - Updated the driver with the review comments.
>>> - Remove the check for the tx fifo full interrupt condition
>>>   form Tx interrupt routine as we are checking it in the _xmit
>>>   routine.
>>> - Clearing the txok interrupt in the tx interrupt routine for
>>>   every Tx can frame.
>>> Changes for v4:
>>> - Added check for the tx fifo full interrupt condition in Tx interrup=
t
>>> routine.
>>> - Added be iohelper functions.
>>> - Moved the clock enable/disable to probe/remove because of
>>>   Added big endian support for AXI CAN controller case(reading
>>>   a register during probe for that we need to enable clock).
>>> Changes for v3:
>>> - Updated the driver with the review comments.
>>> - Modified the tranmit logic as per Marc suggestion.
>>> - Enabling the clock when the interface is up to reduce the
>>>   Power consumption.
>>> Changes for v2:
>>> - Updated with the review comments.
>>> - Removed the unnecessary debug prints.
>>> - include tx,rx fifo depths in ZYNQ CANPS case also
>>> ---
>>>  drivers/net/can/Kconfig      |    7 +
>>>  drivers/net/can/Makefile     |    1 +
>>>  drivers/net/can/xilinx_can.c | 1176
>>> ++++++++++++++++++++++++++++++++++++++++++
>>>  3 files changed, 1184 insertions(+), 0 deletions(-)  create mode
>>> 100644 drivers/net/can/xilinx_can.c
>>
>> Mark: Any update on this one?
>> BTW: When you apply these patches you should apply 2/2 before 1/2. The=
re
>> is new checking for binding.
>>
>=20
> Ping?

Done, when you repost, can you change the order of the patches, so that
the binding comes first.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--9CxfKEqGoHewKFOiBSMidlRv0KJjxfEu1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNWLzYACgkQjTAFq1RaXHNYFQCfcqxljLE6h68CrKf3hvHif2Pk
tMgAnR9nVNBljRf/Sbo8yh0b+kLg0pia
=dEH0
-----END PGP SIGNATURE-----

--9CxfKEqGoHewKFOiBSMidlRv0KJjxfEu1--
