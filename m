From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 17:34:49 +0100
Message-ID: <1163954089.15473.16.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163895673.15473.11.camel@johannes.berg>
	 <20061119155628.GA25061@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5p1dk9E06ysYc1phQWbx"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5801 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756768AbWKSQgi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:36:38 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061119155628.GA25061@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5p1dk9E06ysYc1phQWbx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 07:56 -0800, David Kimdon wrote:

> What is wrong with the driver setting the function pointer to NULL for
> the cards that do not support scanning?  Where does this requirment
> come from that the function pointers in struct ieee80211_wiphy be
> identical for all cards?

Well I want to allow drivers to make assign the 33 function pointers in
a static structure, and differences between cards must then be handled
in the non-static part.

johannes

--=-5p1dk9E06ysYc1phQWbx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYIeo/ETPhpq3jKURApS2AJ9pRwI164hZBW/uf2I2VwePeqvQEACfXszD
HlNznGVNzQyC02bmahtwzKU=
=SJFV
-----END PGP SIGNATURE-----

--=-5p1dk9E06ysYc1phQWbx--

