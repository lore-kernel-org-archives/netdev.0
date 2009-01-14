From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 09:56:31 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901140954250.27308@anakin>
References: <1231836016.3212.41.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760867AbZANI4t@vger.kernel.org>
In-Reply-To: <1231836016.3212.41.camel@jaswinder.satnam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2009, Jaswinder Singh Rajput wrote:
> Please pull these patches. Earlier I also floated these patches so that I can get some feedback.
> 
> The following changes since commit ae2659bcd0b5bf34dd4b03f1db0a2942cc09b8e6:
>   Ingo Molnar (1):
>         Merge branch 'x86/mm'
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tiptop.git master
> 
> Jaswinder Singh Rajput (7):
>       include of <linux/types.h> is preferred over <asm/types.h>
>       found __[us]{8,16,32,64} type without #include <linux/types.h>
>       capability.h: extern's make no sense in userspace
>       coda_psdev.h: extern's make no sense in userspace
>       in6.h: extern's make no sense in userspace
>       nubus.h: extern's make no sense in userspace
>       socket.h: extern's make no sense in userspace

May I please remind you of my comment in
http://patchwork.kernel.org/patch/2093/?

At least nubus.h still leaks forward declarations for kernel functions that
lack the "extern" keyword, so they still pollute user space.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
