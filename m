From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 17:23:18 +0200
Message-ID: <4E3FFF66.6090602@pengutronix.de>
References: <1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>
	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>
	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>
	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>
	<20110808144424.GY4926@sgi.com>	<4E3FF9EA.6030601@grandegger.com>
	<20110808150925.GA4926@sgi.com> <4E3FFE61.4090109@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3243258195918183166=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E3FFE61.4090109-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============3243258195918183166==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6EB1E10BBF22A52EC1DD5A31"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6EB1E10BBF22A52EC1DD5A31
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 05:18 PM, Wolfgang Grandegger wrote:
>>>> Our contact with Freescale would prefer that I not post that patch u=
ntil
>>>> we get the OK from freescale to do so since we received it under NDA=
=2E
>>>
>>> I don't think we currently need it. I prefer dropping and cleaning up=

>>> the device tree stuff as it is not needed for the P1010 anyway. If a
>>> new processor shows up with enhanced capabilities requiring
>>> configuration via device tree, we or somebody else can provide a patc=
h.
>>> Marc, what do you think?
>>
>> I will rebase shortly and provide a newer set of patches.
>>
>> I do think powerpc does need the device tree support.  That is how the=
 flexcan_probe
>> is getting called.  How would you suggest I do it otherwise?

I think Wolfgang was talking about removing the clock* attributes from
the device tree, not the device tree bindings at all.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6EB1E10BBF22A52EC1DD5A31
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4//2YACgkQjTAFq1RaXHOGTwCePKui96sl07mG9YnE88HA5Gbm
nwsAn0FFnwhDwk/oSod1zT0WQaiViB6c
=90XF
-----END PGP SIGNATURE-----

--------------enig6EB1E10BBF22A52EC1DD5A31--

--===============3243258195918183166==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3243258195918183166==--
