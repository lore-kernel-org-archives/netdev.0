From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 17:57:39 +0200
Message-ID: <1149695859.3925.11.camel@johannes>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes>  <4486F513.5050906@lwfinger.net>
	 <1149695470.3925.7.camel@johannes>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6hkmdfEnycGTC3RTx1C2"
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46981 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932252AbWFGP5s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 11:57:48 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <1149695470.3925.7.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6hkmdfEnycGTC3RTx1C2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-06-07 at 17:51 +0200, Johannes Berg wrote:

> Well, it should be shown in the 802.11i spec too.

I suppose that it is the association request, and needs to contain the
RSN described in 7.3.2.25 as per 7.2.3.4 in 802.11i. This is, afaik, the
'generic IE' that is added with the wext. Now, it looks like the RSN
isn't included but the WPA2 info or something? Also, the genIE in your
log doesn't look correct to me, starting with ffffff?? Jouni, do you
have any idea what might be going on?

johannes

--=-6hkmdfEnycGTC3RTx1C2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARIb3caVg1VMiehFYAQJlIg/+NZT5sa6d4RKvyzYzQOFLJxOT9DMfMJCk
EygE9r/9Pgb5tLslWaKyxBVD0IOUw3GLgCB9qDYtqBeJx20gEfRquqKfdjv/oQb9
Rc1Y7jCPM7hfCxbuKPQdWIyBXTJJdsTD88nL2xzXBuR9tb3W9AprGRaisvMYVg4d
F0hL/dA3rUnK20nM5gPcxOnVHFkPOBPUg2oxWMQwQNaE0uEwc2gRk/OEEY5b19eg
/VSGXYXZfcO63qxm/YN0p70+hQZ9wCevgZCQBVqH2ADE1AvjWg/NWhrd6TheCsSS
ozR8NBOmuWJqQZ9dVHG/ieb4sn/KZhmQFauLleaYJym0RjhjzHLFfkfEV9XNutH/
3+Awgdr4aLBbt35p0sBjH4oZnzvwwKcl/KR+2yzGTV80M0UTwctk1dP4eYzwtks8
8W08TcxcNngvAooB1mzM4dNcmyjZp+ybPKxc/G+1QKX9dFIH6wZjXX/jLAB5WcXb
nw+Dd4gdK3bJxmfWlCgxxBqASHF3JFnkIxycyX/oNkSz8w6Mw92mrJFETVTRtcSq
GxieajUpdfytNVGLe4rU+G7pEs9SkxZspyLF5xWm1AbhBx7CE90f0xViiYPnaQfn
cJl26R69MJ3VSfk9hnnOdiB40td79RNWTcI91OFxp41IpVg2YMC2w5wCgRqxfroF
a4zxnmCOZFo=
=8RIn
-----END PGP SIGNATURE-----

--=-6hkmdfEnycGTC3RTx1C2--

