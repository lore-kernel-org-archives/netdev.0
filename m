From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Wed, 22 Dec 2010 07:52:41 +0100
Message-ID: <4D11A039.5090006@pengutronix.de>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>	<4D0BD454.3060503@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEAE47E1A@EAPEX1MAIL1.st.com>	<4D0FBEF6.8020207@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAE481B6@EAPEX1MAIL1.st.com>
	<4D10FF97.1070703@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAE48416@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3570859613320424658=="
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAE48416-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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
--===============3570859613320424658==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig140982C0B90D243BD0DA7824"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig140982C0B90D243BD0DA7824
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/2010 04:36 AM, Bhupesh SHARMA wrote:
> Hi Wolfgang,
>=20
>> Hi Bhupesh,
>>
>> On 12/21/2010 05:48 AM, Bhupesh SHARMA wrote:
>>> Hi Wolfgang,
>> ...
>>>> In the meantime I compared the CAN chapter of the PCH manual with
>> the
>>>> C_CAN manual. The paragraphs I checked are *identical*. This makes
>>>> clear, that the "pch_can" is a clone of the  C_CAN CAN controller,
>> with
>>>> a few extensions, though. Therefore it would make sense, to
>> implement a
>>>> bus sensitive interface like for the SJA1000 allowing to handle both=

>>>> CAN
>>>> controllers with one driver sooner than later. Therefore, could you
>>>> please implement:
>>>>
>>>>   drivers/net/can/c_can/c_can.c
>>>>                        /c_can_platform.c
>>>>
>>>> Then an interface to the PCI based PCH CAN controller could be added=

>>>> easily, e.g. as "pch_pci.c". You already had something similar in
>> your
>>>> RFC version of the patch, IIRC.
>>>
>>> This was the approach I initially proposed in my RFC V1 patch :)
>>> But unfortunately we could not agree to it.
>>
>> I know. But at that time I was not aware of any other bus used for the=

>> C_CAN controller.
>>
>>> So, please let me reiterate what I understood and what was present
>>> in RFC version of the patch. Please add your comments/views:
>>>
>>>         - drivers/net/can/c_can/c_can.c (similar on lines of
>> sja1000.c)
>>>         i.e. a)no *probe* / *remove* functions here,
>>>              b)register read/write implemented here.
>>>
>>>         - drivers/net/can/c_can/c_can_platform.c (similar on lines of=

>> sja1000_platform.c)
>>>         i.e. *probe* / *remove* implemented here,
>>
>> Yes, that's what I'm thinking about.
>>
>>> Marc and Tomoya can also add their suggestions so that I can finalize=

>> V3 a.s.a.p.
>>
>> That would be nice, indeed. Also have a look to Tomoya's PCH driver,
>> which also looks very good in the meantime.
>=20
> I am having a look at Tomoya's PCH driver, but as I mentioned in=20
> RFC V1 patch, I would rather like to have a bus sensitive `c_can` drive=
r

What do you mean by a "bus sensitive" driver?

> on top of which we can have the platform driver `c_can_platform` which
> essentially caters to the details of registers mapping/arch differences=
=2E
> Any other functionality like USB/PCI should be present in a separate fi=
le
> like `usb_c_can.c` or `pci_c_can.c`=20

Sounds like the sja1000 approach, which is a good choice.

> If you agree I will try to circulate V3 a.s.ap.

go ahead.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig140982C0B90D243BD0DA7824
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0RoD0ACgkQjTAFq1RaXHNmBQCfaIgb38YLZDagHDKnmhr0bsu+
t7wAnA/u2mVAKXqeipupoB5HUMV5ilw4
=FIBi
-----END PGP SIGNATURE-----

--------------enig140982C0B90D243BD0DA7824--

--===============3570859613320424658==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3570859613320424658==--
