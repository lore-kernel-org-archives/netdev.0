From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 23:37:00 +0200
Message-ID: <1245274620.31588.49.camel@johannes.local>
References: <1245267218.31588.41.camel@johannes.local>
	 <m18wjqwoca.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7rPwgis2NOHb/F+hYcCl"
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37255 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbZFQVh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:37:29 -0400
In-Reply-To: <m18wjqwoca.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7rPwgis2NOHb/F+hYcCl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 14:19 -0700, Eric W. Biederman wrote:

> Nothing at first glance looks wrong.

Will review locking :) Not sure I hold enough locks at the correct
places here.

> Most of these genetlink things are network related so making it
> network namespace aware makes sense.

Well, some are non-network, and some are network, like nl80211. My goal
is this patch:
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/016-cfg80211-net=
ns.patch

It already kinda works, but has bugs like not going back to init_net if
the ns a wiphy is in exits, and some more like that.

> My impression had been that genetlink was mostly not network related
> and I would have to solve the other hard problem of how to filter
> sockets based on other namespaces.  I guess that can be delayed for
> a while longer.

Ah, well, I was thinking that the generic netlink family code would have
to take care of that.

johannes

--=-7rPwgis2NOHb/F+hYcCl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOWH5AAoJEODzc/N7+Qma4dgP/2nU/zVJ3voHLRKkblBCnbyA
9WNpWTMLz1TKofpmGI12DC8ruFAZU7dY4XaQBxhoJk8ZJtWiwmN4CspNLBSdgltW
AagepYss2OG64+KzW7Xjk80SKQ28IOhov1k/xVsLGz4RR623duVwangbHF5YUh/h
v+Yk4QC4lYfQ7ILZPAaXEK7/G9wDWGrEsu2rN3APYXykHLlE6gsMA44rHS1dWDpv
mClu0n49Ulf4hvMVcMcShqlgR12O33u8WrcRE8wkDcHGpTdkyVXyuhvyyjFgMH8Z
BY3vHN1I01jlfQN5WIR6/EDT6US/Q+2CZGcD7/0aBATZGqtXjo41JiZfwqraNs6V
7g5x5iFhBoGM1uvgNX0yMlnVqsJjJA/v0aRsDX3G4ONXDL0in9OHwoQbIjKeDxnJ
VVC7INmZUI3tuC32b+QSzddeMmAYxJOfKVxASKSyi48hvIxBci7q0Fb5fTgHRjpR
KU/ZSNCDB6kfmRn3x+nPhz8P6Vpius0xiLDR1zivocWzEz7PrHsJqm4XSgf5MwLv
iEaiKQ+UrK3dqSEDdZmfKBBCiRyDLXi3GENpflBGceEeoC4yWEO0MSU19/EkQF5o
g8j9bQ90Mj7S3YLdpgiJzLRIGgDHNHuPsL/siEGO8jT0yC08q9slKHQyJFlo/VeN
1fGAt3Fk9ro9cNbk5L4O
=G5MB
-----END PGP SIGNATURE-----

--=-7rPwgis2NOHb/F+hYcCl--

