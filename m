From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:19:27 -0700
Message-ID: <4810A4FF.7030004@redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>	<20080424112514.055d8071@the-village.bc.nu>	<517f3f820804240534r3bbbdc52s52a6dfe3f2d14b7f@mail.gmail.com>	<48109DFB.900@redhat.com> <20080424154220.3dae36a1@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	michael.kerrisk@gmail.com, linux-man@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762605AbYDXPUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:20:53 -0400
In-Reply-To: <20080424154220.3dae36a1@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:
> We shouldn't be seeing this as a Linux problem, its a BSD problem, an=
 AIX
> problem, a Solaris problem and an HPUX problem and really wants one
> solution applying across distributions or it will harm everyone in th=
e
> long term.

Look at the other interfaces.  I've proposed them for POSIX and they ar=
e
going to be in the next revision (O_CLOEXEC, F_DUPFD_CLOEXEC).  I'm
confident that whatever we'll do will be endorsed this way.  It's just
too late for the next revision, it'd have to wait a few years until wor=
k
on the next revision (esp reviews) start.  That's too long.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIEKT/2ijCOnn/RHQRAkyoAJ9/FRwN3r6zg2cSvzVrA2TiGlfergCdG1r9
H/UghrO5A99ieG6O7wXvu7I=3D
=3DpUfi
-----END PGP SIGNATURE-----
