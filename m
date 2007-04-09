From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 22:29:17 +0200
Message-ID: <1176150557.8459.47.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-lixq4CV6YEBERVLNiOwD"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58357 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbXDIU3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:29:12 -0400
In-Reply-To: <461A9DF1.8080904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lixq4CV6YEBERVLNiOwD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-04-09 at 22:11 +0200, Patrick McHardy wrote:

> Thats why I suggested that we should create one, ideally before adding
> more sysfs/proc/ioctl/... based interfaces, which we'll have a hard time
> getting rid of again.

But then how would we configure initial parameters along with creating
the interface? That's something that's good to have, and I don't see how
you can allow it generically.

Then again, you can of course always add an interface and then change
its operating parameters etc. but that isn't atomic any more.

johannes

--=-lixq4CV6YEBERVLNiOwD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGGqId/ETPhpq3jKURAueIAKCGMhjHxdXROv6ESN7tXft6ENdOPACeJU8A
nOHvUtLTgN30dkb9puWD1DQ=
=pmaM
-----END PGP SIGNATURE-----

--=-lixq4CV6YEBERVLNiOwD--

