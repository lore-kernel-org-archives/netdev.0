From: Ben Hutchings <benh@debian.org>
Subject: Re: [PATCH net-next 1/4] bnx2x: LSO code was broken on BE platforms
Date: Sun, 12 Dec 2010 04:14:53 +0000
Message-ID: <1292127293.3136.261.camel@localhost>
References: <1291808589.30114.65.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-p0aUrZZvH1wBb09PdS4t"
Cc: Dave Miller <davem@davemloft.net>,
	netdev list <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56777 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752507Ab0LLEPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 23:15:30 -0500
In-Reply-To: <1291808589.30114.65.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-p0aUrZZvH1wBb09PdS4t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-12-08 at 13:43 +0200, Vladislav Zolotarov wrote:
> Make the LSO code work on BE platforms: parsing_data field of=20
> a parsing BD (PBD) for 57712 was improperly composed which made FW read w=
rong=20
> values for TCP header's length and offset and, as a result, the correspon=
ding=20
> PCI device was performing bad DMA reads triggering EEH.
[...]

This fix looks like it should go into the stable/longterm series.  Since
this driver has changed a lot since 2.6.32, you would need to provide a
backported patch for that.

Ben.

--=20
Ben Hutchings, Debian Developer and kernel team member


--=-p0aUrZZvH1wBb09PdS4t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATQRMN+e/yOyVhhEJAQIGQRAAofXQ1KJoa8mxZtUW45381b8cZAA5EVmO
Lm75OKn9jTYQhjrQY/KQqL62Dq16TY8M/AnJoH7SzR07+aDrPHguGEGzwS5ICFlw
Df/+Gg71WT8xxsY2pwqcK8fJ/omLgZj8ZTyQY//bc69eKMC0qEVfw2UE8gTomhK7
24yHMSBz/Z/Lbm+fzRKeZx54KZp8b06Hw6Mg+k44iuf8GP2O8CkevsJ1TTQ4e+mh
dvCrKcMtbSUBzcODWDUcJuSmtCSTT3UmcB9CDU7v9D+NZ+5Z2jaemzDl8QToXxH2
aB2XkXb6SXseGxOL5nbOLqIg7PF4LBIyi0n8FgXMuPxSsBglTmULCTadGm5kdiLa
Sx5F34Hv7mb4pMCL8b5QviRzd8/pNBbNvDI20V42/Q6qWEPYCBRXYR1o7h9Dofl6
XqkEMC9/Yd4NoWumHL2LArC/1q2b8Q1l0boDuAMpnIvnTCW3wJKh14YwkeYJcFd2
acmGA6v3PZPrzzB997V+H2fFRSSFbH/mvEsErxBU6ABnakAjX9lW69G+KgeCdB3Y
XIDn3+gUqxKr9pRoktyKFBIbHzdotvZFseQ2fbmCgHTjYCSE+3h5P4sdL+23hQx9
aRnXbVxCEvNOV1sRh+MRFsnic9lWyCo2DzkVtvGh/BwHLEPCFReMINufL/0nkJ8S
JJSjVwt+PlU=
=Swf4
-----END PGP SIGNATURE-----

--=-p0aUrZZvH1wBb09PdS4t--
