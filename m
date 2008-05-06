From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 20:10:46 -0700
Message-ID: <481FCC36.2010801@redhat.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>	<20080505185850.789d870a.akpm@linux-foundation.org>	<481FC38A.6070805@redhat.com>	<20080505194221.4349418b.akpm@linux-foundation.org>	<481FC94C.8090203@redhat.com> <20080505200500.0d1018df.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754557AbYEFDK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 23:10:58 -0400
In-Reply-To: <20080505200500.0d1018df.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> What I meant was "what does this whole patchset do"?  Believe it or n=
ot,
> for a new reader, that is somewhat unobvious.  Perhaps one could work=
 it out
> with sufficient googling and thread-trolling.

It adds flag parameters in all the places where none is present to
control aspects of the returned file descriptor(s).  So far atomic
close-on-exec and setting non-blocking mode are implemented.  More can
follow if wanted.  Similar to the O_CLOEXEC and F_DUPFD_CLOEXEC
extensions which I wrote several moons ago.  Just two weeks ago I point=
ed at

   http://bugzilla.redhat.com/show_bug.cgi?id=3D443321

as a case which we cannot really fix without these kind of extensions.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIH8w22ijCOnn/RHQRAjNvAJkBJxBR3uI8HfPIUqcMezLjFK/d2QCfXS4v
IH7T6AFb/j9V4tWtlWi0Bcs=3D
=3DlLFY
-----END PGP SIGNATURE-----
