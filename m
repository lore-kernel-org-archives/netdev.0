From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/2] sh_eth: Fix asynchronous external abort
Date: Mon, 24 Nov 2014 09:41:18 +0100
Message-ID: <CAMuHMdVeB0DmTr-xNHnZsHWao78Mdfk87+hThmiRu7qyZHMKWA@mail.gmail.com>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
	<1415862135-27972-3-git-send-email-ykaneko0929@gmail.com>
	<20141124011759.GA5089@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20141124011759.GA5089@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 2:18 AM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Nov 13, 2014 at 04:02:15PM +0900, Yoshihiro Kaneko wrote:
>> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>>
>> When clock is disabled, Ethernet register access raise Bus error.
>
> I have spoken with Kimura-san and the problem may be reproduced by
> calling ethtool with -s of -G while the network interface is down.
>
> e.g.:
> ifconfig eth0 down
> ethtool -G eth0 rx 512

That makes sense.

I think it would be good to add the reproduction steps to the commit message.

> I have confirmed that the problem above appears in net-next
> and appears to be resolved with this patch and the previous on
> in this series (which seems to be a dependency) applied.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
