From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Tue, 06 Mar 2007 15:31:20 +0100
Message-ID: <1173191480.5415.2.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Z0M8FVW2QCgJi18CfauM"
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50810 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965082AbXCFOeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 09:34:44 -0500
In-Reply-To: <1173144447.15891.93.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z0M8FVW2QCgJi18CfauM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-03-06 at 02:27 +0100, Johannes Berg wrote:
> Actually, I think it may have the same bug, it seems to be operating
> with iw_point (or at least its size) too

I'm told that the code that uses it is only internal and the size isn't
part of the userspace interface which makes this wrong. But we still
have many programs relying on ioctls and none relying on the wext/nl
interface so that isn't really a concern anyway.

johannes

--=-Z0M8FVW2QCgJi18CfauM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF7Xs4/ETPhpq3jKURAqz4AJ0Y5WKHzeZiz4h+cNxAj24WCl4hKQCglXeW
1RHWnx8ZFpPAYEyWKaHNQ0o=
=hegF
-----END PGP SIGNATURE-----

--=-Z0M8FVW2QCgJi18CfauM--

