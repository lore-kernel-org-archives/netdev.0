From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 18 Feb 2011 09:36:22 +0100
Message-ID: <4D5E2F86.1020400@pengutronix.de>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>	<20110211152026.GC373@e-circ.dyndns.org>	<32A5399EB727427C98185089E5DBFA65@subhasishg>	<4D5E2570.10108@grandegger.com>
	<184FA07B783D4F5FAAC09D5C11737A3F@subhasishg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2046626799966229354=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <184FA07B783D4F5FAAC09D5C11737A3F@subhasishg>
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
--===============2046626799966229354==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig29289A3F93AD7CE69E97EE56"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig29289A3F93AD7CE69E97EE56
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/18/2011 09:15 AM, Subhasish Ghosh wrote:
>> On 02/18/2011 08:07 AM, Subhasish Ghosh wrote:
>>> --------------------------------------------------
>>> From: "Kurt Van Dijck" <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
>>
>> ...
>>>>> + /* register interrupt handler */
>>>>> + err =3D request_irq(priv->trx_irq, &omapl_rx_can_intr, IRQF_SHARE=
D,
>>>>> +   "pru_can_irq", ndev);
>>>> you're doing a lot of work _in_ the irq handler. Maybe threaded irq?=

>>>>
>>> SG -Ok, will do
>>
>> No, please use NAPI instead.
>=20
> We are using h/w filters, so the number of interrupts coming into the
> processor are not hogging it.
> I feel that we may not require an interrupt mitigation.

As davem stated the other day, all new drivers should use NAPI.

regards, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig29289A3F93AD7CE69E97EE56
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1eL4kACgkQjTAFq1RaXHOVkQCeK+Zl73Wk6m1Xb2aOmDaPynho
/a0An230G7HFRSAi0jqrt47PEQyCNbGd
=n3+U
-----END PGP SIGNATURE-----

--------------enig29289A3F93AD7CE69E97EE56--

--===============2046626799966229354==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2046626799966229354==--
