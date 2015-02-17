From: Matthew Thode <mthode@mthode.org>
Subject: getting a list of naked interface names from iproute2
Date: Mon, 16 Feb 2015 18:07:12 -0600
Message-ID: <54E28630.4020200@mthode.org>
Reply-To: mthode@mthode.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="WIvLWntvTFekWG3CQ261fbBxB7KBrRvX0"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-82-208-22.static.grandenetworks.net ([216.82.208.22]:34626
	"EHLO mx1.mthode.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbBQARJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 19:17:09 -0500
Received: from [IPv6:2001:470:e1cc:2:8871:4a62:3bea:60bd] (unknown [IPv6:2001:470:e1cc:2:8871:4a62:3bea:60bd])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.mthode.org (Postfix) with ESMTPSA id 9CFB11CBD8
	for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 19:07:48 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WIvLWntvTFekWG3CQ261fbBxB7KBrRvX0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

iproute2 seems to like to add @ and : info to it's output.  This makes
parsing it hard for things like neutron (openstack).  I have a patch to
slightly update it (still missing some things, I'll link it at the end
if interested).  Is there a better way of getting interface names from
iproute2 without having to strip out at characters like '@' and ':'?

changeset in neutron: https://review.openstack.org/#/c/154128/
link to current code:
https://github.com/openstack/neutron/blob/master/neutron/agent/linux/ip_l=
ib.py#L110-L131

I'd appreciate your help, I'd rather not have to go through each link
type to pull it's delimiter, but if needed I guess it's needed.

--=20
Matthew Thode


--WIvLWntvTFekWG3CQ261fbBxB7KBrRvX0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJU4oYwAAoJEGSje+quGaToJIkP/jzdDY/2cpla7bY8ATqVZMfZ
aYKOWFjkxPQto7EDiS6vijVywbJOXwdNdnJEz8YFxuzfir+Ti/ueR9/hKlBOumuz
PPQ7UVvTiAf0JeLV5S2pCvRrUzNKDEFh8dAHuD/B0N5DV7NohM/HMDaFIs+oe5eh
HiQk5FIGgVU1BC5+mpTkHs1faseTQIgl+AvFu+V1Ru3Ket7Id3vDB9wK8zrd54k6
6VFAZ0XjafYx6YEj4vyDePbVeQzmxigPtMkxrJzpf9JgkAj7wLTTfjyVBI5tePTt
nFokmXrCRG5xlwio9RhlYO+LEJ929zZpv3uJfX+Iw0UiNl0lMlFlq5umWdosBzJw
X0rXO3mNTe9Mr7fGuxUrM6nyy6MghA91wGkr2kUO4qSfjsltGWKqNVZ/skz4HZZ2
jC2yM81+xQ5o0qw3BHBnFMadzngL3SEWWWDGoECADzjfdkYP9R+HsEiyzF1WJVI5
EiZEKKyxfo9+TCenpbwpbhsTEJjriSEjYr9t5Plb7+eRs8Jf9Ba3l8U87+Ym9U23
V8BSj9jRxSF8ZJLgdhwQ62QKe6dekG6yo1WSMleQTC1r5nftWiLTguGu2r6oWxKC
ggNCtW98EQpXGZaLu+xAVNRIFr3KNqlyykHDMgu75dzsmaevmj7GrwXAM6ounKXF
0NjUP8fcAwectdIZBW6x
=/KsK
-----END PGP SIGNATURE-----

--WIvLWntvTFekWG3CQ261fbBxB7KBrRvX0--
