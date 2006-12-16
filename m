From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: linux-2.6.20-rc1-gd1998ef3 build #203 failed
Date: Sat, 16 Dec 2006 18:12:49 +0300
Message-ID: <20061216151249.GA28463@2ka.mipt.ru>
References: <200612161546.47455.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56477 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161044AbWLPPTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 10:19:54 -0500
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Content-Disposition: inline
In-Reply-To: <200612161546.47455.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 16, 2006 at 03:46:45PM +0100, Toralf F=C3=B6rster (toralf.f=
oerster@gmx.de) wrote:
>=20
> Hello,
>=20
> the build with the attached .config failed, make ends with:
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `__inet_check_established':
> inet_hashtables.c:(.text+0x2b338): undefined reference to `net_statis=
tics'
> inet_hashtables.c:(.text+0x2b35d): undefined reference to `net_statis=
tics'
> net/built-in.o: In function `inet_twdr_do_twkill_work':
> inet_timewait_sock.c:(.text+0x2babb): undefined reference to `net_sta=
tistics'
> net/built-in.o: In function `inet_twdr_twcal_tick':
> : undefined reference to `net_statistics'
> net/built-in.o: In function `tcp_enter_memory_pressure':
> : undefined reference to `net_statistics'
> net/built-in.o:tcp.c:(.text+0x2e2c1): more undefined references to `n=
et_statistics' follow
> net/built-in.o: In function `inet6_create':
> ...
> net/built-in.o:(.data+0xfff8): undefined reference to `inet_accept'
> net/built-in.o:(.data+0x10010): undefined reference to `inet_shutdown=
'
> net/built-in.o:(.data+0x10024): undefined reference to `inet_sendmsg'
> make: *** [.tmp_vmlinux1] Error 1
>=20
> Here's the config:

I've built your config just fine with
d1998ef38a13c4e74c69df55ccd38b0440c429b2 (the latest tree for now)  git=
 -=20
either you have some misconfiguration in scripts, or you got version in=
=20
the middle of struct transformations.=20

--=20
	Evgeniy Polyakov
