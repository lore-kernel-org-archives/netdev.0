From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:16:59 -0700
Message-ID: <4810A46B.1090809@redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>	<20080424112514.055d8071@the-village.bc.nu>	<481096C3.2020206@redhat.com> <20080424152436.6cf53c1b@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760089AbYDXPSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:18:06 -0400
In-Reply-To: <20080424152436.6cf53c1b@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:
> There are only a small number of valid socket types recognized by POS=
IX
> plus a few BSD plus a few Linux ones so Linux can happily assign the
> upper bits for a different purpose.

You didn't read what I wrote.  It's about the not-yet-assigned types.
=46or those the implementer must ensure that during the development no
value is used which can conflict with any current and future assigned
value and not with any other development.  Hence common practice is to
use a random value over the entire range.

I don't know about a case for socket but this is definitely how (sane)
development elsewhere works.


> Every other property of a socket via accept() is inherited from the
> parent. Making one property different would be bizarre and ugly.

Implementing this would visibly change existing code and it would
actively violate POSIX.  Not a good idea.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIEKRr2ijCOnn/RHQRAoltAJ98g8GHGSYceIJxyddjCRI6otoVagCfeTXC
TfgaalHo6XQEzehnST+unhk=3D
=3DT272
-----END PGP SIGNATURE-----
