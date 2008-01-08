From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Tue, 08 Jan 2008 18:32:41 +0100
Message-ID: <1199813561.6762.13.camel@johannes.berg>
References: <11983602942818-git-send-email-bjd@jooz.net>
	 <20071223011707.1798C2360C6@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	 <1199304827.8532.31.camel@localhost>
	 <200801080319.23299.david-b@pacbell.net>
	 (sfid-20080108_111935_296045_A569FA94)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oNmtRVchPmDQJX1+25Q+"
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200801080319.23299.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> (sfid-20080108_111935_296045_A569FA94)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-oNmtRVchPmDQJX1+25Q+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I see that the rndis_wext.c Kconfig won't kick in unless the
> 802.11 stuff is available ... what additional dependencies
> does that imply for a fatter rndis_host module?

No extra modules are currently required for just plain wext [1]. In the
future, we hope to migrate stuff to cfg80211 though, which is a separate
module.

johannes

[1] mostly because all the code is simply compiled into the kernel...

--=-oNmtRVchPmDQJX1+25Q+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR4OzuKVg1VMiehFYAQLe/hAAknDzmyudpbpX8NP8zUV46pVuKx2T/tUi
KbQVTTM+e2e63ODPBI4uLjgLMgLriXI7gtQNGVF53syGCbpW6iOltxY1GBGhJzhD
0TLVK21Ql5341RHyQVMDnm7RFmSSP7lHAwmzMwVMbz8h39Id/MCsu02uXsfUmNDA
EXEcvWrz87uefsGc+WbISCz5SqSqMcMTO40PWi/deuiKf+NekeLNmag70r4jRnKF
hY66JG441xm+89AtGpGpEJKhDtHkqmt5odA6ZnezOjrOTRo+Y29y35bxFyHKdIxX
7kWI9kYtCFHwOcNyoNpaGjuZpy21fgPFJNRoPi1C872fKnsQF8MCelbgfyW2VXqe
20DlhLBTVCzW0fHYfcFpLmtFdeoFPR9EyzhN3K0pWNEKvhAMQPKvVMqOhreoBRYy
J+VoJol6UAgUYRJN23ZE/3JC+k13WTB7Fyl8zyuw3Ww0CWB1T1KpLEEq1Jq6cVcE
6jpXc4O/P6NohOgcX3SoKnxSjuQ6b6JBX783j8IqQRj6ZLdXrqD/3M2cxdskk+Dr
7Fu9iiUnwusGRrCwUekjHcQv9B5fOQIFN/jYbFogUSt3CJVpuZ7MQ/vUyiAsU+gJ
uR9vNSWTttPgRBLPKwbnMdHmvMyv/Om9qrPdtexN7tSFKpn/H27Uhm28TsmXjUFM
DBoZhp3GqLM=
=AegI
-----END PGP SIGNATURE-----

--=-oNmtRVchPmDQJX1+25Q+--
