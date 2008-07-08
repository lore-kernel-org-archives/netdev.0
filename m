From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 08/11] remove CONFIG_KMOD from net
Date: Tue, 08 Jul 2008 20:42:03 +0200
Message-ID: <1215542523.3670.4.camel@johannes.berg>
References: <20080708170015.470877000@sipsolutions.net>
	 <20080708170047.433712000@sipsolutions.net>
	 <20080708183035.GC11954@cs181140183.pp.htv.fi>
	 <1215542220.3670.0.camel@johannes.berg>
	 <20080708184017.GD11954@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Y2eLXq1wAcsohgb78VOv"
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:45112 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYGHSmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 14:42:51 -0400
In-Reply-To: <20080708184017.GD11954@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Y2eLXq1wAcsohgb78VOv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Eh, no. Not unless I also always compile in dev_load, which as of now
> > depends on CONFIG_MODULES. In fact, another hunk in this series makes i=
t
> > a static inline when CONFIG_MODULES=3Dn so that callers don't need to t=
ake
> > care of #ifdef'ing it.
>=20
> Look at include/linux/module.h:
>=20
> ...
> #ifdef CONFIG_MODULES
> ...
> #define EXPORT_SYMBOL(sym)                                      \
>         __EXPORT_SYMBOL(sym, "")
> ...
> #else /* !CONFIG_MODULES... */
> #define EXPORT_SYMBOL(sym)
> ...

Oh, right, I forgot I was dealing with CONFIG_MODULES and treated it
just like another config option, thanks.

johannes

--=-Y2eLXq1wAcsohgb78VOv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIc7T3AAoJEKVg1VMiehFYaC8P/RGyVxvAz+3vuAVfu6qUrFSc
O1M3Y1L7SzsLfd9IhKZ3jjePEBd5U+cUj4osPnSwJQCO2cItTEB2wOyV9lZHheo8
UubXeaYQP1+c5wQafUa0D+q1272m8Njp1hn3mww2N7YhAMC0Yhzfil1mKW4ru4+N
3ogcyNfsnUzXbGqnSz3JC7LkD/KmVcRoduCzmpKZI/D1udO/JhONxsTYsfTOq40I
MDq3zXZSDfqoq4rDTXnxBDpT+0FDbcGOJtOE8jBZk98JvAKmHkz5pyQp5TKzVYL9
5vhvNQJtYfe8gyiQSP7zhNK2o/0KCVBm/Q/Djjsso+o55eW1tQpJ2kJzY7igpzvA
lgox5ywmHJFKTEhRIhIjyw1Sy3Tib15KfLOL13j5DipkaHAjcf6CRjMvkOl0/uRx
+lgwfQTnRnv5MiLw8Qqy+dyHe+Y8kc/8psOcLxWZwI6RYtdEUr4sRpnSrpeiAdsJ
6kVTTsfiukV7VQUFW9/R5qczcbUkjd17ocio6GkXAdygifWHl+G9IbbclL3yVOEA
DXVUyn6wYu9exJfnqel3IE4RjG2syVhBhH2l9L/qlyPAMvXPfMEqTJmwyRxCUJkp
CcssSzUI5qnK4Atl8o48qNRBZdXhaBDGo5HBxUmFIuUCQrlvFdRzAH7fn/TbOG+j
LaNaWfzhjxaCnDCoDvJb
=Vg/y
-----END PGP SIGNATURE-----

--=-Y2eLXq1wAcsohgb78VOv--

