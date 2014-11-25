From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] sh_eth: Fix asynchronous external abort
Date: Tue, 25 Nov 2014 09:10:10 +0900
Message-ID: <20141125001005.GA5656@verge.net.au>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
 <1415862135-27972-3-git-send-email-ykaneko0929@gmail.com>
 <20141124011759.GA5089@verge.net.au>
 <CAMuHMdVeB0DmTr-xNHnZsHWao78Mdfk87+hThmiRu7qyZHMKWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdVeB0DmTr-xNHnZsHWao78Mdfk87+hThmiRu7qyZHMKWA@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 09:41:18AM +0100, Geert Uytterhoeven wrote:
> On Mon, Nov 24, 2014 at 2:18 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Thu, Nov 13, 2014 at 04:02:15PM +0900, Yoshihiro Kaneko wrote:
> >> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> >>
> >> When clock is disabled, Ethernet register access raise Bus error.
> >
> > I have spoken with Kimura-san and the problem may be reproduced by
> > calling ethtool with -s of -G while the network interface is down.
> >
> > e.g.:
> > ifconfig eth0 down
> > ethtool -G eth0 rx 512
> 
> That makes sense.
> 
> I think it would be good to add the reproduction steps to the commit message.

Yes, I agree entirely.

> > I have confirmed that the problem above appears in net-next
> > and appears to be resolved with this patch and the previous on
> > in this series (which seems to be a dependency) applied.
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
