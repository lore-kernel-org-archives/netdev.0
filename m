From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH] batman-adv: Fix NULL pointer dereference in DAT hash
 collision avoidance
Date: Fri, 15 Feb 2013 09:30:29 +0100
Message-ID: <20130215083029.GK6973@ritirata.org>
References: <1360664325-7323-1-git-send-email-paukoning@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qo7zVO9a9OQ5oQtr"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: Pau Koning <paukoning@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28550 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab3BOIb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 03:31:27 -0500
Content-Disposition: inline
In-Reply-To: <1360664325-7323-1-git-send-email-paukoning@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qo7zVO9a9OQ5oQtr
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 12, 2013 at 11:18:45AM +0100, Pau Koning wrote:
> An entry in DAT with the hashed position of 0 can cause a NULL pointer
> dereference when the first entry is checked by batadv_choose_next_candida=
te.
> This first candidate automatically has the max value of 0 and the max_ori=
g_node
> of NULL. Not checking max_orig_node for NULL in batadv_is_orig_node_eligi=
ble
> will lead to a NULL pointer dereference when checking for the lowest addr=
ess.
>=20
> This problem was added in 785ea1144182c341b8b85b0f8180291839d176a8
> ("batman-adv: Distributed ARP Table - create DHT helper functions").
>=20
> Signed-off-by: Pau Koning <paukoning@gmail.com>


Hello Pau,

thank you very much for this fix, this was not an easy one!

However, next time please CC our mailing list as well (get_maintainer.pl wi=
ll
give you all the needed addresses), otherwise it may be the case that we
overlook such patches and:
1) we don't review it
2) we don't merge it into our repository (which is where the real developme=
nt
   goes on).

Both 1) and 2) happened with this patch and, in my humble opinion, it is no=
t a
good idea to merge such delicate fixes without having a reply from the
maintainers.

Therefore, please keep us in the loop when sending patches. It would be rea=
lly
appreciated.


Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--qo7zVO9a9OQ5oQtr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRHfIlAAoJEADl0hg6qKeOUtcQAKoc+S+ZXAJo8yIY+uRVbOUv
Irj41zKTkg0Enop239VrNVy0SFvnNq0abJH4iq/mqe67meFR5lyHKO9B+i2Ss4KR
wD2rR/4kTw5Fr7GSKHv4qHgz3dofdHoRD+gSg1oQFgxcPvAApGOEKpdIalZ5VepJ
Ogev2GooBCdu/k6i7qtjnerowoMWkvWT3ijdOwwgb51Z7Zmnv3LmkrSzDCTVzDE6
rlWPskG5fMqZ4c3iXO/F+CBld9mLytQeLSPOExxJ/xDIEj0mg4MKfH4ly4P8542D
Bz3hUjIrareq/ufKKJxNxErgHfZkIt5KIskXMlrZmUOzvRduZWQBbOuwAtX4Q+gg
srLeJHaIAHZCaXaVDd93CJQHQrXIOBOV+20oS9KhxLC7YOAh8JFgaHErKNuxjVPT
mOo3TYfbSa7+KMHX2JNzXQ69gvZlkREef4aJa6gC4UjJP7fxWRLxgsmrIH+Ys39R
+oeu2k1nuMZd0dtoA/MYbiil3rd2yE3kC9CKyFZkysFkXv4fzH5GM/015bTEatPi
nvwXzLY9wVLjUzWEk8q6FUNAllFc9cf8QPEYVc4aVKzmDFn1Bm/4qFk/2IbhfYQe
u3UkZbp3b/J8AZGmIRzaRXdl0L7v2q1fL53LcXKPuWOtc1y0Ty1uPrB/ziykp7so
7LfBYlOFv18dnsze9P6e
=4pp9
-----END PGP SIGNATURE-----

--qo7zVO9a9OQ5oQtr--
