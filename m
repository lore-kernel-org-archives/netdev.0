From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Generic netlink interface help
Date: Sun, 27 May 2007 15:24:56 +0200
Message-ID: <1180272296.3604.64.camel@johannes.berg>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
	 <1180024477.18003.11.camel@johannes.berg>
	 <20070525221802.GO521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wgfsj2vv07MYHxKYri0B"
Cc: Samuel Ortiz <samuel@sortiz.org>, giometti@enneenne.com,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59296 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbXE0N1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 09:27:25 -0400
In-Reply-To: <20070525221802.GO521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wgfsj2vv07MYHxKYri0B
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-05-26 at 00:18 +0200, Thomas Graf wrote:

> This area is still work in progress but the basic idea is that
> like in kernel context, the application defines its set of
> commands and assigns message parsers for each command.=20

Ok, but why? For when we get asynchronous events from the kernel?

> For now,
> the message parser is linked into the cache operations which
> means that you have to "update" a cache in order to use this
> feature.=20

What's the cache good for to start with?

My current userland tool just send a message and expects back a
response. Obviously that's broken once we have events too, is that when
the message parsers come in?

johannes

--=-wgfsj2vv07MYHxKYri0B
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGWYan/ETPhpq3jKURAk3iAJ9q9xyOh39T7JjBAB7TkdDHmi5iXACgiW+I
CzN14IVjLuWNq2RGY5Vz85M=
=Z/3E
-----END PGP SIGNATURE-----

--=-wgfsj2vv07MYHxKYri0B--

