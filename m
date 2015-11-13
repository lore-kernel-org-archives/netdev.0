From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net] ravb: Fix int mask value overwritten issue
Date: Fri, 13 Nov 2015 11:45:28 +0100
Message-ID: <CAMuHMdXLtR84Cormbh6HbB7fE6mMh9e-0EX5kavmSGHJKLZRAA@mail.gmail.com>
References: <1447410289-3741-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1447410289-3741-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kaneko-san,

On Fri, Nov 13, 2015 at 11:24 AM, Yoshihiro Kaneko
<ykaneko0929@gmail.com> wrote:
> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
>
> When RX/TX interrupt for Network Control queue and Best Effort queue
> is issued at the same time, the interrupt mask of Network Control
> queue will be reset when the mask of Best Effort queue is set.

Nice catch!

At first I was a bit puzzled why this would make a difference, but
the key is "will be reset in the next iteration of the for loop", which
falls outside of the visible context.

> This patch fixes this problem.
>
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
