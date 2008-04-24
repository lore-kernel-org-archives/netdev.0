From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative^2 to sys_indirect: socket, socketpair
Date: Thu, 24 Apr 2008 09:37:47 -0700
Message-ID: <4810B75B.20202@redhat.com>
References: <200804241618.m3OGI9kd013025@devserv.devel.redhat.com> <20080424170325.569afa43@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbYDXQiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 12:38:04 -0400
In-Reply-To: <20080424170325.569afa43@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:

>> -int sock_map_fd(struct socket *sock)
>> +static int sock_map_fd_flags(struct socket *sock, int flags)

sock_map_fd is exported to modules.  Isn't it a big no-no to change
those interfaces?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIELda2ijCOnn/RHQRAoXZAKCAnv7JAup2v6KukBp59LDELfNUeACgvuET
eBYx7ErX8E27VLxlYOdeXjs=3D
=3DD+sf
-----END PGP SIGNATURE-----
