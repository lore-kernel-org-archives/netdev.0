From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 16:46:19 -0700
Message-ID: <44EB974B.3030200@redhat.com>
References: <1156276823.2476.22.camel@entropy>	 <20060822.133606.48392664.davem@davemloft.net>	 <1156281220.2476.65.camel@entropy>	 <20060822.142500.11271092.davem@davemloft.net> <1156287511.2476.137.camel@entropy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB6CCF8FAA9C5BFB78AA61CCC"
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:61854 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932218AbWHVXrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 19:47:06 -0400
To: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <1156287511.2476.137.camel@entropy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB6CCF8FAA9C5BFB78AA61CCC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I so far also haven't taken the time to look exactly at the interface.
I plan to do it asap since this is IMO our big chance to get it right.
I want to have a unifying interface which can handle all the different
events we need and which come up today and tomorrow.  We have to be able
to handle not only file descriptors and AIO but also timers, signals,
message queues (OK, they are file descriptors but let's make it
official), futexes.  I'm probably missing the one or the other thing now.=


DaveM says there are example programs for the current interfaces.  I
must admit I haven't seen those either.  So if possible, point the world
to them again.  If you do that now I'll review everything and write up
my recommendations re the interface before Monday.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigB6CCF8FAA9C5BFB78AA61CCC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFE65dL2ijCOnn/RHQRAjIRAKDHerZO0nBJJh3Bsd0ic26r3ciVGwCfWnrG
jcicCEsTBhBNN7acKknDxqY=
=IhK5
-----END PGP SIGNATURE-----

--------------enigB6CCF8FAA9C5BFB78AA61CCC--
