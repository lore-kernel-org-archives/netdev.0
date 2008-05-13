From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 21:21:29 -0700
Message-ID: <48291749.1060400@redhat.com>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>	<20080512201341.9ead6a9a.akpm@linux-foundation.org>	<482910FA.1080703@redhat.com> <20080512.210225.167924945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbYEMEVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 00:21:43 -0400
In-Reply-To: <20080512.210225.167924945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

David Miller wrote:
> You'll need to handle MIPS and PARISC as well, as they have
> similar conflicts.

Is MIPS really a problem?  The value is 0x80.  128 protocol types shoul=
d
be enough.  Even if not, there is no reason why the numbers should be
consecutive.  It's easy enough to skip over a bit.  I.e., after procoto=
l
0x7f the next one would be 0x100.

And PA seems to have gotten O_NONBLOCK wrong.  SPARC does it right AFAI=
CS.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKRdJ2ijCOnn/RHQRAovKAKDFz2ZJ0E2XYVu5Qn8fME+ieZZopwCgmH4D
ldfvNrhK8LdvjZzNPViILV0=3D
=3DZ9Dj
-----END PGP SIGNATURE-----
