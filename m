From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 20:02:55 -0700
Message-ID: <481FCA5F.1000101@redhat.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>	<20080505185850.789d870a.akpm@linux-foundation.org>	<481FC38A.6070805@redhat.com> <20080505194221.4349418b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562AbYEFDDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 23:03:07 -0400
In-Reply-To: <20080505194221.4349418b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> oh.  More overhead.

One alternative: I can simply do away with the remapping and just
allocate the bits for the new constants (EFD_CLOEXEC) to match those of
the O_* constants.  This means we can still reuse the low bits which
aren't available in the O_* constants.  It means, though, that the
constants are architecture specific since O_CLOEXEC, for instance, has
different values for different architectures.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIH8pf2ijCOnn/RHQRAnlPAKCPxPVuaW+nXpCaxNsPmrAunBqt6gCfetlU
41ZicojDFl0TmVX34p8Z1CA=3D
=3Dq+B/
-----END PGP SIGNATURE-----
