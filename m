From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Tue, 07 Nov 2006 19:52:02 +0100
Message-ID: <1162925522.24531.4.camel@johannes.berg>
References: <1162741174.24574.22.camel@johannes.berg>
	 <20061106210145.6824bec6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Be7RlITIhnLfyxf3iBEf"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59280 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1754278AbWKGS5q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 13:57:46 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061106210145.6824bec6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Be7RlITIhnLfyxf3iBEf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I've put a new patchset up at

http://johannes.sipsolutions.net/files/d80211-cleanup/

It now contains:
001-cfg80211-fix-Makefile.patch
002-cfg80211-wext-compat.patch

as before.

003-d80211-reduce-mdev-1.patch
004-d80211-reduce-mdev-2.patch
005-d80211-cleanup-rxmgmt.patch
006-d80211-scan-sanity.patch

similar to before, but modified to apply without the previous cookie
patch.

I decided to drop the cookie patch because it unnecessarily breaks
drivers. We obviously haven't figured out what we want, so let's just go
for the lowest common denominator.

I think these are mostly cleanups and it all compiles fine after each
one. No API changes. Haven't gotten around to testing it yet.

johannes

--=-Be7RlITIhnLfyxf3iBEf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVDV0aVg1VMiehFYAQKVkg/+NqWtgx1xjEtBvmMqAIFnp+Wk97r5+BvQ
1ocwePf3lu+5LMTfJx8HYm9k/JPBHdqzVYDKufRdUrev19pbnvSfSbztzknIHYjh
mFOp6TVWGEL9abDgc66MzK/K/I9+Ftg9ukg3uNdMA32PglpcauM3mfkAEJBXe70p
NRLHYeMsWv+tuASs53B/DEjHmucIvyxWWvU377Vh3cE0WdU1v2V48bSt4DeIsSMR
fpk/mB8I3C+EvIZTj68UD5h+5Y4LB3EaBprxjXV1xGCFjT3sAlPauLGIZ4YQtDUb
9i+fC9WXua2znnj2jvBAyyK9XitC1wnyG+/2P5pJuG0KOfnjEEJIqU/NvZ1gpAK2
nmCxLT4KzhfnYhDDlknIy07JWJY7G9SZDbIca06e5ibdA+C4hV8i9AI1bLxEAvzB
tPcT1SYc5etinTfAru9fInw7mj8jNSNExs6x3rnSJgzYD/qkHbtNy7+RbRmzsrcO
tSJtludu8J+DPjNHRC3Nv9e31/2SPEy+DFJ8+XrDG7cIqa0FLdwX0ij/OMbgcvH4
XHP60RDSYsTIPMIInrvsYtJqvOjF0/KQuLyzh2L7RcQLge9LH5MPY3luyPZ8DK34
hW5uerENH+7bKbr6/C/BT6BpzsGkK6O24NM/d0QHE9c48Z0EfM7OQPnh1xmn4hfo
k4FcgayXX3A=
=IIlT
-----END PGP SIGNATURE-----

--=-Be7RlITIhnLfyxf3iBEf--

