From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Wed, 11 Apr 2007 18:43:13 +0200
Message-ID: <1176309793.3826.7.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176239819.10381.10.camel@johannes.berg>  <461D09AD.9060603@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MKqt04R1POV4CeclHjU/"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58274 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbXDKQmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 12:42:10 -0400
In-Reply-To: <461D09AD.9060603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MKqt04R1POV4CeclHjU/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-04-11 at 18:15 +0200, Patrick McHardy wrote:

> No, generic netlink avoids allocating netlink families.=20

Well, yes, I thought that was pretty much the point. :)

> br_netlink
> uses the same netlink family as the other network configuration stuff
> (NETLINK_ROUTE), but a different rtgen_family (which matches the
> address families).

Ah ok. I got all the family types confused then.

>  But you have a valid point, if we want to use
> this for things like bonding or VLAN that aren't actually address
> families, we should consider introducing "rtnetlink families" to
> avoid adding AF_BONDING, AF_8021Q etc.

True.

But this still doesn't help wireless which doesn't have either an
rtnetlink family nor an address family since it uses generic netlink
exclusively.

johannes

--=-MKqt04R1POV4CeclHjU/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGHRAf/ETPhpq3jKURAuTfAKCSomPsAZZIUrtyPnw57br22wKfhACfUNsE
F+Tai518L+0q7S+6y/3NWRg=
=islW
-----END PGP SIGNATURE-----

--=-MKqt04R1POV4CeclHjU/--

