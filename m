From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 11 Jan 2011 23:48:41 +0100
Message-ID: <4D2CDE49.3030302@pengutronix.de>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>
	<4D2829C5.5020206@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
	<4D2C14FE.7080903@grandegger.com> <4D2CA0AA.6080505@grandegger.com>
	<4D2CD34B.8000609@pengutronix.de>
	<20110111223843.GB18762@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8078486129850451236=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110111223843.GB18762-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8078486129850451236==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4ECECCE2018BA4BDF89C80C2"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4ECECCE2018BA4BDF89C80C2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2011 11:38 PM, Wolfram Sang wrote:
> On Tue, Jan 11, 2011 at 11:01:47PM +0100, Marc Kleine-Budde wrote:
>> On 01/11/2011 07:25 PM, Wolfgang Grandegger wrote:
>>
>> [...]
>>
>>> I was told that Bosch's page for the C_CAN is here:
>>>
>>>  http://www.semiconductors.bosch.de/en/ipmodules/can/canipmodules/c_c=
an/c_can.asp
>>>
>>> There it's also written for what bus interfaces the C_CAN is availabl=
e for, e.g.:
>>>
>>>   "The ASIC version is delivered with the AMBA APB bus interface from=
 ARM."
>>
>> On ARM we also have the AMBA bus abstraction in Linux, but I've never
>> worked with it. IIRC Wolfram (Cc'ed) has recently touched it.
>=20
> For a programmer, it feels very much like a platform-bus (you can even =
use
> amba-devices on a platform_bus); it has the advantage of some identific=
ation
> registers at the end of the address-space. The rest is more about how t=
o
> connect the core to the SoC. Does that help? I don't know what the actu=
al
> question is :)

No real question so far. Bhupesh is hacking a generic c_can driver and
platform bus bindings. The question might be do we need the platform bus
bindings or is it better to have AMBA bindings? The platform driver
supports 16 and 32 bit attached devices, via IORESOURCE_MEM_{16,32}BIT.

Where do we have to look for the AMBA id registers?

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4ECECCE2018BA4BDF89C80C2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0s3kwACgkQjTAFq1RaXHNNVwCeIgEH/bfVggham+QzE16Zyofh
qoUAn3Y8syOESia3Ro29KoRrFPzfpck/
=8Wz6
-----END PGP SIGNATURE-----

--------------enig4ECECCE2018BA4BDF89C80C2--

--===============8078486129850451236==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8078486129850451236==--
