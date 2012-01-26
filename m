From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: Tree for Jan 25 (net/sock.h, jump_label, memcg)
Date: Thu, 26 Jan 2012 18:18:28 +0100
Message-ID: <CAMuHMdWp1wEHqPXNs+kaMYpomJnfbZPJjRk5GVFCuCL4Q5zK7g@mail.gmail.com>
References: <20120125141938.c1a9460d56948e1c7b26d3f8@canb.auug.org.au>
	<4F2052DB.4060602@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Gleb Natapov <gleb@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F2052DB.4060602@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2012 at 20:07, Randy Dunlap <rdunlap@xenotime.net> wrot=
e:
> back to net/sock.h and jump_label:
>
> (on i386:)
>
> /next/linux-next-20120125/include/net/sock.h:953:2: error: implicit d=
eclaration of function 'static_branch'
> /next/linux-next-20120125/include/linux/jump_label.h:43:29: error: co=
nflicting types for 'static_branch'
>
> Full randconfig file is attached.

Without having to add randomness, also in m68k/allmodconfig, now in Lin=
us'
tree :-(
http://kisskb.ellerman.id.au/kisskb/buildresult/5491860/

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
