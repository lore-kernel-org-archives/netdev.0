From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 12:14:07 -0700
Message-ID: <4829E87F.1070006@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809AbYEMTPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 15:15:39 -0400
In-Reply-To: <200805132037.39580.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

R=C3=A9mi Denis-Courmont wrote:
> In any case, getaddrinfo() should be patched to
> [...]

What should be the behavior is socktype and protocol are zero?  Should
these two types be returned by default?  What others?  So far we return
TCP, UDP, and raw socket information.  I'd rather keep the list short
but since we already have raw sockets in there (because they are in
POSIX) I won't reject anything that's more useful than raw sockets.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKeh/2ijCOnn/RHQRAhTeAJ9jrv+RS6rkrGJvan9ADq4S86d2XQCggST4
/MYPzB+2s2/m1VYsmUPAeLg=3D
=3DFSYf
-----END PGP SIGNATURE-----
