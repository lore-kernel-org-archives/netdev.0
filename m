From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Tue, 08 Aug 2006 23:57:18 -0700
Message-ID: <44D9874E.4020402@redhat.com>
References: <20060808.225230.104030885.davem@davemloft.net> <20060809061159.GA5979@2ka.mipt.ru> <20060809062515.GA23527@2ka.mipt.ru> <20060808.233156.74748104.davem@davemloft.net> <20060809064923.GB7154@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAA19ABAE359D82A88A7D01A3"
Cc: David Miller <davem@davemloft.net>, zach.brown@oracle.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53484 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965085AbWHIG5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 02:57:49 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060809064923.GB7154@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAA19ABAE359D82A88A7D01A3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Evgeniy Polyakov wrote:
> Question with kevents removal from syscall stays open until Ulrich
> accepts or declines mapped buffer implementation.

It was my idea in the first place to use the ring buffer.  I'm sure
others had the same idea but that's what I presented.  So, I see no
reason you should delay making this change because of me.

The only important thing is that we need to get a useful semantics for
fork and exec.  For fork, it must be possible to "dequeue" entries from
the ring buffer in a thread-safe way.  For exec (where a file descriptor
might survive) we likely need a mechanism to mmap the ring buffer only
based on the file descriptor.  I'm not sure about this, though.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigAA19ABAE359D82A88A7D01A3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFE2YdO2ijCOnn/RHQRAlqXAJ0VYtbJskGc355wLbV0XU+zYpKjZwCfYQeb
LAnQ4flsQKMeYwQcug7Sodk=
=BYaH
-----END PGP SIGNATURE-----

--------------enigAA19ABAE359D82A88A7D01A3--
