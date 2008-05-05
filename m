From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
	destructor
Date: Mon, 05 May 2008 13:37:33 +0200
Message-ID: <1209987453.3655.40.camel@johannes.berg>
References: <1209925940.3655.17.camel@johannes.berg>
	 <20080505.002006.225975612.davem@davemloft.net>
	 <1209972675.3655.15.camel@johannes.berg>
	 <20080505.004017.247102504.davem@davemloft.net>
	 <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LIAN4FQSIwGiXt6Uark5"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41789 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbYEELic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 07:38:32 -0400
In-Reply-To: <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LIAN4FQSIwGiXt6Uark5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 12:43 +0300, Ilpo J=C3=A4rvinen wrote:
> On Mon, 5 May 2008, David Miller wrote:
>=20
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 05 May 2008 09:31:15 +0200
> >=20
> > > If we decide to uninline those functions for another reason (used too
> > > much, code size, ...) then we can still do that.
> >=20
> > Agreed.
>=20
> According to my measurements the size bloat of those two is
> (x86/32bit, gcc 4.1.2 redhat something):
>=20
> -1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
> -495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w

So do we want to out-line them? I don't really know the scale involved.
If so I can resubmit this patch with them outlined and the warnings
added (but did you account for the EXPORT_SYMBOL space?)

johannes

--=-LIAN4FQSIwGiXt6Uark5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB7xfKVg1VMiehFYAQIpeA/+NpeTbOnXx7XzcS0etECyRI94W0O5o8x3
NDeNvoFr08a8N3de9zZ7uGSPlfXCFziWNC9+kxfxTQjlxZzbpgHW2LXphqWixJp/
2a8oy1C8q6FE1aJfEdacqMnmMzPp4Xe6B794Xi/zfrsJuw3mAvJVPF5urpfKMaeA
nAC9x++6eZjs3bTsqNJ/15NBrQCGs5rDmLYWdybGOjDldLd+KM68fDUsPgFmq5dF
vn72E/gwPs1PIAMVONNtyrUy7P1QMv3ZhVeTI4trZdKQHJ5ePeqxCEgA7hyqxhhe
mEwrdI3PIDfRLVsd1s2sEQEIYLHt3uIVsvWGlXvZ6ddvDAEo7OjV2T+FlOFunTN/
dcsp+S9uYk6D6wkVgLHqtKfkX5tU2Pn7xlxpwc92dCfzBnXf+3RDkGTSeF+iftQF
hjQrONvLpgg3EGHCB/Csuvzdl85+R+c8OVM81Llc2FATVRlKyAkhgrHj9stBwqZ7
NtfU3Zr3PqysLLn1Ag2MLiaTiRLolD0NbsV3vqrGStGhd4Wfoe9JFus3Q/hAuSqO
R+ORMzLNWxmnGkFoKKJDTpzd+/cuVqf93Yngnmbl4YrD1x93UljxDFL6YPsNyOHv
fwau/hdewHzT6gMXZBNwfefWd6W18QPVgBt5JAc4pMGIh29HRKydA90LkAx1Xuso
4NZEQ5+gFm0=
=KhNF
-----END PGP SIGNATURE-----

--=-LIAN4FQSIwGiXt6Uark5--

