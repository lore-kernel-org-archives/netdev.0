From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] net: phy: add ethtool_phy_{get|set}_link_ksettings
Date: Sat, 07 May 2016 12:59:57 +0100
Message-ID: <1462622397.19332.28.camel@decadent.org.uk>
References: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/e2UIH9RWctcYlyNhFaZ"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, f.fainelli@gmail.com,
	fugang.duan@nxp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51084 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbcEGMAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 08:00:10 -0400
In-Reply-To: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/e2UIH9RWctcYlyNhFaZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-05-07 at 01:18 +0200, Philippe Reynes wrote:
> The callback {get|set}_link_ksettings are often defined
> in a very close way. There are mainly two differences in
> those callback:
> - the name of the netdev private structure
> - the name of the struct phydev in the private structure
>=20
> We add two defines ethtool_phy_{get|set}_link_ksettings
> to avoid writing severals times almost the same function.
[...]

I don't think there's no need to access a private structure, as there's
a phydev pointer in struct net_device. =C2=A0If some drivers don't maintain
that pointer, they should be changed to do so. =C2=A0Then they can=20
use generic implementations of {get,set}_link_ksettings provided by
phylib.

Ben.

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999
--=-/e2UIH9RWctcYlyNhFaZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXLdi9AAoJEOe/yOyVhhEJz+wP/3f2rlvfBG1vgivF7gha2iYf
jFHMbeCQpISCKRBwTLkv9mX6YUXsYHosFLsK05eM4MyvMJnxAf6vmpb1PYkoPQNK
ZpY14Wa6DpWQwRyR3nfxbDIb5vQAsIxPCEZwJ6fCiAxwNC9wBuiBQh+2Fw8tYuKu
MiA3a3CQr2WoZ7NTBsdXDfuEDYRImdD/ZNp8znFjWL4Iv/LTnd+EY0/wf0a5l1uC
SeJH4duG2ZCli6bRC63tQ3GCwScYY0MICC7wLsJQADG5adEB8BPMbgPW1srGPrQH
H4n/W7GnDcf1IRgsHvIvsqR827jnqNsS06eJEwk9qeW4j3fzlBUnt6FfPLwHo/Zt
MxVlvVYQz1+j2FgULE/XGjJT1YS73qNLUFMV91yRf0L419kdqmIvbQepmtihp/iv
DOrJ3c+FUhAalKInxkeuyQ8yBM+w6DraoDAYiib/GmwbCJvt0FADJidqznzrqaQV
C9pmH2D7lhJow6hgfdZT5OrqeRBKRWF2pNVsk+QBRKnqgldd6lkIEhvyolbHYqhK
ayJUWOFz+xFh2Ao8C+xF82KQH5uENA94FWsc+/pckqRxOM9BhEGBhSoucZpLifPH
ISdYtaQwRL6uj/S0t9uzs1KDdzaKeEUKmWiKm3l18fYBLB93Fun16oEYw7qB7TnU
Nz99Nk6rXHupL6GSHZdC
=+ZhM
-----END PGP SIGNATURE-----

--=-/e2UIH9RWctcYlyNhFaZ--
