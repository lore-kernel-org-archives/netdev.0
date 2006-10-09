From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to have
	sameMAC an AP interface
Date: Mon, 09 Oct 2006 23:49:05 +0200
Message-ID: <1160430545.3352.7.camel@johannes.berg>
References: <20061003181118.537800000@devicescape.com>
	 <20061003181233.GE19403@devicescape.com>
	 <1160343128.4701.6.camel@johannes.berg>
	 <20061009213807.GH26254@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-k9AW3AvmNAQ8dU0WAMUZ"
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50629 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964885AbWJIVuj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 17:50:39 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061009213807.GH26254@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-k9AW3AvmNAQ8dU0WAMUZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-10-09 at 14:38 -0700, Jouni Malinen wrote:

> Yes, I just merged in support for this (dynamic VLANs) into hostapd.
> RADIUS Access-Accept is used select VLAN is being used and the STA is
> bound at that point to another virtual interface, if needed.

Cool.

> Well, that would probably be correct for most (all?) cases, but then
> again, I would probably not bother with this level of validation in
> kernel. Whatever is taking care of binding the STA in user space (e.g.,
> hostapd) can do the validation.

Yeah, I guess it's always possible to mess with STAs from the hostapd
since, well, it's the AP :)

[but this also means that I understood the point, so thanks for your
reply :) ]

johannes

--=-k9AW3AvmNAQ8dU0WAMUZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARSrD0KVg1VMiehFYAQLNlw/9GxN9Vwfbd2rEH2vzOTgBSJnAJV7OKatc
D16ndaCtZOtwQuPqWw6T81+2XId3fUuUpRG+Bc+Ujd748r/uiINQh/WOa1koQm8h
16N6zb3soOTVZs/yhylyk2mxSoLmLfn6hz25412i4XDarlydL7oL1+VFaoGfx6Of
OOFcnDM6e+KDZks6TJ5WfNFTyh2QHpNyk0ECeEtLDMKpI+XMD9lBRozYmejEylyp
owWou6Vc19Ykf3KQkbPJm8w+RKLhbiRI3x9wFCaETHep6cZdwBKdfOTYb0NdBPr1
Ie+G8zxt6pjKn7wKVt83WEZ//MaoFsjZRodXisefzVHiCZwrkFCDG5vYfrvr27jT
pSYNbn9rhZKWnkfsSan8KoahMi/u3D7n7MR5FG2lIZg9fQfYejeKcG3Lql/Gb+WB
ymHikb7z34ifOnevH5AJxEnN/PtH7e4MmqeuusFyCcLwytrAesNX30BEyh1gDvyq
nZxBosdQNhAOj3M/Z4JHvjq/qQYNUQ5rK90RvFU+4rAMu2J6+z4nbAogf5DEDll8
mZnTPQJrdW9vSlKYCJrmxSQaOG4QyV4orL92mCN9D8ZjYeqiaB+F6btRt8sBtau+
/wnJL/j3EWIEeN/kyXFAc9DEOlfzHxVtyGnQ+TV31LJhok/M08d35nqkQujPoTVD
Yo/h1L5ojbU=
=ykGg
-----END PGP SIGNATURE-----

--=-k9AW3AvmNAQ8dU0WAMUZ--

