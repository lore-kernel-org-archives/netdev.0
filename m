From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Sun, 04 May 2008 22:00:05 -0700
Message-ID: <481E9455.7030704@redhat.com>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com> <20080505.132452.98853465.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756844AbYEEFDb@vger.kernel.org>
In-Reply-To: <20080505.132452.98853465.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

> To me, it seems overriding 2nd argument is a too ad-hoc workaround,
> and introducing new syscalls with flags is cleaner, e.g.,
>     psocket(family, socktype, protocol, flags);
>     psocketpair(d, type, protocol, int sv[2], flags);

While I agree, you missed the initial discussion where Alan, DaveM, and
Linus expressed preference for this overloading.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkgelFUACgkQ2ijCOnn/RHSt1ACgx5ksBu0jMDqZDcG01PmJ4Jel
EywAoKLQ8pEKcB+bY+vDzaOaZvLyPag0
=3D6iYM
-----END PGP SIGNATURE-----
