From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 22:42:50 -0700
Message-ID: <48292A5A.4050606@redhat.com>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>	<20080512201341.9ead6a9a.akpm@linux-foundation.org>	<482910FA.1080703@redhat.com>	<20080512.210225.167924945.davem@davemloft.net>	<20080512220416.ef9a9645.akpm@linux-foundation.org>	<482922E2.3040902@redhat.com> <20080512221917.07cf7b06.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758127AbYEMFno@vger.kernel.org>
In-Reply-To: <20080512221917.07cf7b06.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> Different bug, I think.
>=20
> net/socket.c: In function 'sys_paccept':
> net/socket.c:1543: error: implicit declaration of function 'set_resto=
re_sigmask'

Right, that's the signal mask stuff.  Should be fixed by the other patc=
h
I sent.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKSpa2ijCOnn/RHQRAmPvAJ90D3ZHrIWs1ZE5K9XVEdZBh8vcdQCePcaw
1Hnyz58x9oizIXe6qiS82xU=3D
=3Do78L
-----END PGP SIGNATURE-----
