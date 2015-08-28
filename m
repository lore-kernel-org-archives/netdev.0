From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/2] sh_eth: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 17:39:25 +0200
Message-ID: <CAMuHMdUQv5OwnD9FNxnuXmCGn9Aaa2DLv27XMRTZhCSktiF2Lw@mail.gmail.com>
References: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
	<1774140.R12mtes975@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1774140.R12mtes975@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2015 at 3:56 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> The driver overrides the error returned by platform_get_irq() with -ENODEV
> which e.g. precludes the deferred  probing from working. Propagate the real
> error code to the driver core instead.
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
