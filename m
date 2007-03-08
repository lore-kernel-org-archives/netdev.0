From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 20:08:29 +0100
Message-ID: <1173380909.3248.52.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
	 <20070308184954.GA24485@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Owow9V7uGucuRzHDN7qh"
Cc: Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34611 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933073AbXCHTIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 14:08:46 -0500
In-Reply-To: <20070308184954.GA24485@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Owow9V7uGucuRzHDN7qh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 10:49 -0800, Jean Tourrilhes wrote:

> 	A proper fix would involve forcing the alignement in the
> kernel. Unfortunately, that would break 64bit->64bit configs. I think
> I can build a workaround for this in iwlib.

Not easily I think. You'd have to get something that has a well-defined
result and see whether padding is present or not. The MAC address might
be good enough (due to len being 24 instead of the expected 20) though.
Thing is that it's really hard to figure out (even at runtime) whether
the kernel and machine are 64 or 32-bits.

I'd think this is a kernel bug and 32-bit userspace should rightfully be
able to expect 32-bit aligned structs, no? Actually fixing it in the
kernel would not be trivial though.

johannes

--=-Owow9V7uGucuRzHDN7qh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8F8t/ETPhpq3jKURAmVzAJ0R8hALSlT5Zo0BxzEFU9q/9A9rFwCguWu5
IPd+GkNIZrlLtwzw3SCNlCw=
=Bd4T
-----END PGP SIGNATURE-----

--=-Owow9V7uGucuRzHDN7qh--

