From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
	destructor
Date: Mon, 05 May 2008 14:04:11 +0200
Message-ID: <1209989051.8245.3.camel@johannes.berg>
References: <1209925940.3655.17.camel@johannes.berg>
	 <20080505.002006.225975612.davem@davemloft.net>
	 <1209972675.3655.15.camel@johannes.berg>
	 <20080505.004017.247102504.davem@davemloft.net>
	 <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
	 <1209987453.3655.40.camel@johannes.berg>
	 <Pine.LNX.4.64.0805051452300.1888@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1gRD6NuMRo411QZrxo9s"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52541 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbYEEMFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 08:05:15 -0400
In-Reply-To: <Pine.LNX.4.64.0805051452300.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1gRD6NuMRo411QZrxo9s
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > (but did you account for the EXPORT_SYMBOL space?)
>=20
> Not really. I don't even know how to measure such...

I guess it's not much, it seems to be an unsigned long, a pointer and
the name string.

johannes

--=-1gRD6NuMRo411QZrxo9s
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB73uaVg1VMiehFYAQJuoA/9GT+AJG/HCPpPbov3AmqfI7q/mrkkAWIe
Yeukt6eBk9oBHb1g3cm/hYYX4RpaPWx4YwCIB4MXIFAqKhd14DvsIBrQznClmyA8
V7gTddJtxoRMq0+1hHNVp/nA48aOG3s8JNopJp8EtscG1RGQDeA231da8ZOqpmnd
QY7tb8yTcNUgVgiktNwLU+7N7zYD0oYAcAUfLupGGc2jWo9X42DIKsvncs5jaB6Q
1V8IrgWkyjcHn3s2M4k3X+kXLM7nFGDNeKo9lnY5Mkt6aGTjC6XYgc3kgaxoKykH
p3mRWhqeU8J5GhkOAPgtfKK45iwkG2jwDAa1PTRBf2a+rj+78SyF4qG83VDdhE/8
OT4mV8D3M7IiIHJv79+PTquItKcusScwWS90lSUiEylM0HyieSpa4pZf9C/kpEds
O2GSigFRofE8/eOuSJ1eF53Xree9bBVHT8lNVdCMGb8yH44GgUSOl9YJMicPZLZE
g+JW2ZY5xV0ZMhuZxF/xOonFesgi1eAOYpMrjffsuxu7iwIMX7HA06P1HH7NqG1N
JbLs1Oa6TH4VgE83M1pb6vLkQOorxTPoUYh+Ajm62Dc1Tz9eTS4PjxmxQoNMETXc
1OqY87EHFVRe8HeafJbctn1VbQl2e8TMhuqEqVU62ql3iqAjm/GRpZNjs92lNMm0
qwjsrpB95Mg=
=MP4o
-----END PGP SIGNATURE-----

--=-1gRD6NuMRo411QZrxo9s--

