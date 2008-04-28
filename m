From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] paccept, socket, socketpair w/flags
Date: Mon, 28 Apr 2008 07:13:31 -0700
Message-ID: <4815DB8B.7060606@redhat.com>
References: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com> <517f3f820804280252h753c8cacv7fe9580f96dcf1ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932454AbYD1ONt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 10:13:49 -0400
In-Reply-To: <517f3f820804280252h753c8cacv7fe9580f96dcf1ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Michael Kerrisk wrote:
> This is ugly.  Why invent a diffent set of flags here.  I agree with
> your earlier statement that new syscalls would be cleaner.

Don't lay words in my mouth.  I do think that different flags are
needed.  The name of the flag must indicate what it is for and you don'=
t
want to mix flags with different prefixes for the same flags parameter.
 Not introducing separate flags would mean all the functions would have
to accept the same set of flags which will sooner or later create
problems.  I really don't see the problem here.


> then *please* let's go the hwole way cleanly, and have new syscalls
> also for socketpair() and socket(), and make all of the new syscalls
> use the same flags.

Hell, no, that's worse than everything else proposed.  We don't have th=
e
luxury to have a separate parameter to indicate close-on-exec or not.
=46or efficiency it has to be a multi-purpose flags parameter and the
flags each syscall takes are different since the functionality is diffe=
rent.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIFduL2ijCOnn/RHQRAhV5AKDK924ANx9HO5qDbPyB6m4uegbABACgpkFA
AOO7/HaCFNe/GNmNlEJXBag=3D
=3D18Bc
-----END PGP SIGNATURE-----
