From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Fri, 23 May 2008 07:31:06 -0700
Message-ID: <4836D52A.5030600@redhat.com>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com> <20080522222246.0526f8f8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757222AbYEWObh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 10:31:37 -0400
In-Reply-To: <20080522222246.0526f8f8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> 	BUILD_BUG_ON(SOCK_NONBLOCK !=3D O_NONBLOCK);

After the addition of arch-specific SOCK_NONBLOCK values this line must
go.  I thought one of my patches already did that.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkg21SoACgkQ2ijCOnn/RHQG2wCeNS8o/cVxuOYXRbCnwFTg1rcx
590AoIvJBnwNP9O26kIHNY3ExVTA2M2a
=3D5P4P
-----END PGP SIGNATURE-----
