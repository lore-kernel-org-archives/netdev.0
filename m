From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: ip6_tables warning (was: Re: Linux 2.4.27-pre6)
Date: Thu, 17 Jun 2004 12:06:17 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.58.0406171139020.22919@waterleaf.sonytel.be>
References: <20040616183343.GA9940@logos.cnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
        "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040616183343.GA9940@logos.cnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is not a new problem, but I never bothered to report it before:

| ip6_tables.c: In function `tcp_match':
| ip6_tables.c:1596: warning: implicit declaration of function `ipv6_skip_exthdr'
It needs to include <net/ipv6.h> to kill the warning.

Sorry, no patch, since my development machine is offline.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
