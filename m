From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 09:49:09 -0700
Message-ID: <46F15305.2030507@redhat.com>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761968AbXISQti@vger.kernel.org>
In-Reply-To: <p73sl5aveqh.fsf@bingen.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andi Kleen wrote:
> The standard way to undo connect is to use AF_UNSPEC. Code to handle
> that for dgram sockets is there. It's the same code for v4 and v6.

I quoted the standard and it does not say anything about AF_UNSPEC.  So
you cannot simply make such broad statements.

I also don't say that this behavior should be removed.  It's certainly
useful, very much so in fact.

But the spec calls for a "null address" to be used and that's in my
understanding something different from using AF_UNSPEC.

I looked through Stevens TCP Illustrated Vol 2 and it seems not to
mention resetting the address at all.  The POSIX spec certainly got thi=
s
text from .1g.

I cannot test it on other systems.  If somebody has access to some
certified systems (and maybe others), write a bit of code which creates
a DGRAM socket, connect to one address, call connect with a "null
address", then connect to another address (which likely has to use a
different interface since otherwise the connect will just succeed, it
seems).

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8VMF2ijCOnn/RHQRAr9NAJwLxyql0kQnMGJNaPZlRGsuB6rGEACgog88
WIWAFhuBWsjps7PdbcoumUQ=3D
=3DoLxP
-----END PGP SIGNATURE-----
