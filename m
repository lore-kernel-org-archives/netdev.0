From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:45:45 -0700
Message-ID: <4810AB29.5030604@redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>	<20080424112514.055d8071@the-village.bc.nu>	<481096C3.2020206@redhat.com>	<20080424152436.6cf53c1b@the-village.bc.nu>	<4810A46B.1090809@redhat.com> <20080424160352.30f2dd5b@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49776 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762708AbYDXPqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:46:30 -0400
In-Reply-To: <20080424160352.30f2dd5b@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:
> Kernel socket type values are assigned by the kernel team so that
> isn't a problem.

Again, it's not about assigned values.  It about those not yet assigned=
=2E

> POSIX has no interface for this new behaviour you propose so that is
> complete crap. The moment you use one of these features you stepped
> outside of the POSIX spec - and you know that. If there was an existi=
ng
> standard we wouldn't have a problem.

Oh really?  You open a server socket, use fcntl(FD_CLOEXEC), and then
accept().  This is identical to the new behavior and it is very well
defined in POSIX.  Hence, code which uses fcntl() this way today will
see a change with your proposal.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIEKsp2ijCOnn/RHQRAl7yAJ40IosF+DLjiFtmuOt/t9LShBt46ACfbVi6
BXwZE0fKUAh0Iqmrme3On6A=3D
=3DiDY5
-----END PGP SIGNATURE-----
