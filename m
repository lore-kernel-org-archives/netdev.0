From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 22:10:58 -0700
Message-ID: <482922E2.3040902@redhat.com>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>	<20080512201341.9ead6a9a.akpm@linux-foundation.org>	<482910FA.1080703@redhat.com>	<20080512.210225.167924945.davem@davemloft.net> <20080512220416.ef9a9645.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244AbYEMFLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:11:10 -0400
In-Reply-To: <20080512220416.ef9a9645.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> m68k too..

I cannot build it here but looking at the headers:

- - include/asm-m68k/fcntl.h does not define O_NONBLOCK; and therefore

- - the definition from include/asm-generic/fcntl.h is used which is 04=
000


Is there any magic I miss?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKSLi2ijCOnn/RHQRAvItAJ45n2h20UasryYucg18pd9ERWUpbACglsvR
ftad99qXQ20UwezP0DjbssA=3D
=3Dorzm
-----END PGP SIGNATURE-----
