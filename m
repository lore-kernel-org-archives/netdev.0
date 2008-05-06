From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 19:58:20 -0700
Message-ID: <481FC94C.8090203@redhat.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>	<20080505185850.789d870a.akpm@linux-foundation.org>	<481FC38A.6070805@redhat.com> <20080505194221.4349418b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562AbYEFC6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 22:58:32 -0400
In-Reply-To: <20080505194221.4349418b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> Sorry to sound slow, but what do we gain from all this?  Your coverin=
g
> description was heavy in references to some earlier discussion to whi=
ch I
> obviously paid little attention and now I'm lost.

What we gain is that the only change for a new flag is a new entry in
the appropriate table.  The reference to non-sequential file descriptor=
s
refers to

  http://lwn.net/Articles/236724/

Not this specific incarnation of the functionality, but something like =
this.

A few more points:

- - for the socket functions we can share the table

- - in most cases the loop isn't even entered since the flag value is
  zero.  In any case, the loop is ended once all flags have been mapped

- - in case this code is really called often, than the code is in the
  cache and it is shorter than each of possible multiple copies of the
  unrolled loop


Anyway, we spent already far too much time on this.  If you want to see
it changed tell me.  It's really not important.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIH8lM2ijCOnn/RHQRAta6AKC39ty8FdiRYjRxxHDoG2T/N1hhywCeKPcZ
L/iDtbf9DozMmEfoLY8nlbk=3D
=3DB+YO
-----END PGP SIGNATURE-----
