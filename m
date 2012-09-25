From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 25 Sep 2012 12:34:38 +1000
Message-ID: <20120925123438.bbf3126889513ee5cc195e5c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Sep_2012_12_34_38_+1000_hl2iGq5KLdJwKIz0"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:50404 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094Ab2IYCer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 22:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__25_Sep_2012_12_34_38_+1000_hl2iGq5KLdJwKIz0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv4/raw.c between commit ab43ed8b7490 ("ipv4: raw: fix icmp_filter
()") from the net tree and commit 5640f7685831 ("net: use a per task frag
allocator") from the net-next tree.

They are basically the same patch (for this file) except the net-next
version adds two pr_err() calls. I used the net-next version and can carry
the fix as necessary (no action is required).

I do wonder if this change belongs in the net-next patch?
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__25_Sep_2012_12_34_38_+1000_hl2iGq5KLdJwKIz0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQYRg+AAoJEECxmPOUX5FEvBQQAJYJ29JrZtYr7fD13ud+KoK8
cvvC8gAsU4JcZgEuH2JzrHoMUuzFrAQH0o/7/+bUZcSKxqVPJnTsdWOEh4K4Vkuc
rfWSYvm8qB6TfOKQhMTtGb8C3GNa0LNjixivjuaVOdGRjXOUK5xsToMXQF0o9Phu
vV8l7RaXWc8R0D41JV+kzS9wSg3HcY77nK5rv/BHGXLfBchRlS++EWAUuWFwGyKD
gJl6RFAfwKJ+SJf+QpZ9x1JpeEdgIkiTVuZ47SjgHYlvjWl7l8qUeR5gZfMqyLmC
n3wipR+z1wwy23LCYkPWo/YJtvMHK8SS5pZIusMCrHzJLW88aDrW0/6yXfHg4O/h
q9vcDKBv1a+O6c8WAfvHWLnFhzNdDJdLGp3dQYse/tenF4y796KlB8beyK1i16pH
sqp8zgndOwlVtJ5Vxg/sC6Po2fhpcGBQlTa7z0Sw3kRef4BhCSnPTQlsEg7Qs5lJ
aPWxY/Ek1ilEK7lcMyT1vhBjOmsYyn02JV4h8t97hld/vOF5jHglXDWP+0hcUWzW
NqsKGIUYTNH2tXksh+irOfc7Uww4qqWkc2UilaoS7fUfxAFB8K3L4dm9S7H3Txtf
6qFJJca+n2PLEO1XzwJ82YqkAH43tH6mAtI01SWDmjjaBw/dPgGsnwz6ji0KhNBv
1IOTrbMlUTqbIEGzVrxY
=NSXf
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Sep_2012_12_34_38_+1000_hl2iGq5KLdJwKIz0--
