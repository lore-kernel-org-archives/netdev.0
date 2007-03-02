From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: s390 allmodconfig
Date: Fri, 02 Mar 2007 12:11:48 +0100
Message-ID: <1172833908.3482.20.camel@johannes.berg>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
	 <20070302002512.bd9bbb80.akpm@linux-foundation.org>
	 <1172831904.3482.13.camel@johannes.berg>
	 <20070302030646.0930d263.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-NETme3ailwwPvW4RlEPh"
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57162 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423023AbXCBLMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 06:12:45 -0500
In-Reply-To: <20070302030646.0930d263.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NETme3ailwwPvW4RlEPh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-03-02 at 03:06 -0800, Andrew Morton wrote:

> No, s390 doesn't have PCI.

Ok.

> s390 is weird ;)   There's no way it'll support any of the hardware which=
 you're
> working on (until they release the s390 laptop).  So all we really want t=
o
> do here is to avoid breaking s390 allmodconfig.

Alright. I think we'll probably have to make bcm43xx and b44 depend on
SSB instead of selecting it like the LED trigger stuff below.

But I don't see why s390 can't include hw random, led trigger or even
hid, those are all software features afaict.
=20

> OK, I'll try that, thanks.

Not that it'll actually help get the compile through... bcm43xx will
drop fail and bluetooth probably as well.

johannes

--=-NETme3ailwwPvW4RlEPh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF6AZ0/ETPhpq3jKURAjsUAJ9mz6gUJ5kkNlaGkhF9b4l8WrSRjgCfXRBZ
PHzIk6MUMule4O9fA6ItCkc=
=39nE
-----END PGP SIGNATURE-----

--=-NETme3ailwwPvW4RlEPh--

