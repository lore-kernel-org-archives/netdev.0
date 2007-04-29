From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [GIT PATCH net-2.6.23] IPV6: Configurable IPv6 address
 selection policy table (RFC3484)
Date: Sat, 28 Apr 2007 23:39:22 -0700
Message-ID: <46343D9A.8010201@redhat.com>
References: <20070419.162856.20840698.yoshfuji@linux-ipv6.org> <20070428.231707.39159334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1EB54E42AFC36708670C8B4F"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203AbXD2Gjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Apr 2007 02:39:45 -0400
In-Reply-To: <20070428.231707.39159334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1EB54E42AFC36708670C8B4F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> One idea is to have glibc have some kind of socket open, subscribed
> to a group which gets "sticky" events.

I don't quite yet know the context but I have to intervene: keeping
sockets open is not good.  This will only cause problems.

Any interface must be memory based.  Something like "register a word
which is set when an event arrives" is a much better interface.  Who you
then go and retrieve messages is another issue.  If this is a rare event
then opening is new netlink socket is no problem.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig1EB54E42AFC36708670C8B4F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGND2a2ijCOnn/RHQRAljqAJkBY5V8E81/S5UUJwGtNzlJ1LJQAQCgtBQX
zyY1CsD8XMUKk/RHpcI3F40=
=8yYg
-----END PGP SIGNATURE-----

--------------enig1EB54E42AFC36708670C8B4F--
