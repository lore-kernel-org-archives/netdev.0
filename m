From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Tue, 13 Dec 2011 13:59:22 +0100
Message-ID: <4EE74C2A.9040908@pengutronix.de>
References: <4EE61928.10608@grandegger.com> <4EE61E3D.2090303@pengutronix.de> <4EE62141.8010305@grandegger.com> <4EE7416E.8070203@grandegger.com> <4EE74AC5.9050404@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig61C0AC5C43E5B9EDB5EF269A"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE74AC5.9050404@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig61C0AC5C43E5B9EDB5EF269A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/13/2011 01:53 PM, Wolfgang Grandegger wrote:
>> I got my MX35PDK board working and can confirm, that the patch works o=
n
>> a i.mx35 as well. My testing also confirms, that the ESR TWRN_INT,
>> RWRN_INT, FLEXCAN_ESR_BOFF_INT do not function as documented. These
>> flags do show up once, together with ERR_INT, and then, after clearing=
,
>> never again. Obviously a bug in the Flexcan logic. From the feedback w=
e
>> can say, that only the i.MX28 does behave differently (=3D=3Dcorrectly=
). All
>> other seem to work with the current code:
>>
>>  Flexcan on
>>  - i.mx25
>>  - i.mx35
>>  - i.mx53
>>  - P1010/P1020
>=20
> But unfortunately, state change reporting looks different with this pat=
ch :)

Hmm - so not schedule for stable. What about your buf-off-handling, will
this change the reporting again?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig61C0AC5C43E5B9EDB5EF269A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7nTCoACgkQjTAFq1RaXHM00ACfVvBYEoSlzU5Genm+F7zFlTk5
t0kAnAtaQ636SCdFoi5B7MomPMirsGdm
=AosD
-----END PGP SIGNATURE-----

--------------enig61C0AC5C43E5B9EDB5EF269A--
