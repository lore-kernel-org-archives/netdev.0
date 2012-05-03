From: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 03 May 2012 13:21:12 -0700
Message-ID: <1336076472.27487.82.camel@wwguy-huron>
References: <1336017985.12425.9.camel@edumazet-glaptop>
	 <4FA21087.1080801@gmail.com> <1336022373.12425.24.camel@edumazet-glaptop>
	 <20120503.012502.44731688706812861.davem@davemloft.net>
	 <20120503151418.GJ9285@tuxdriver.com>
	 <1336058659.27487.80.camel@wwguy-huron>
	 <20120503170727.GM9285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120503170727.GM9285-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

On Thu, 2012-05-03 at 13:07 -0400, John W. Linville wrote:
> On Thu, May 03, 2012 at 08:24:19AM -0700, Guy, Wey-Yi wrote:
> > Hi John,
> > 
> > On Thu, 2012-05-03 at 11:14 -0400, John W. Linville wrote:
> > > On Thu, May 03, 2012 at 01:25:02AM -0400, David Miller wrote:
> > > > From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > Date: Thu, 03 May 2012 07:19:33 +0200
> > > > 
> > > > > My last patch against iwlwifi is still waiting to make its way into
> > > > > official tree.
> > > > > 
> > > > > http://www.spinics.net/lists/netdev/msg192629.html
> > > > 
> > > > John, please rectify this situation.
> > > > 
> > > > The Intel Wireless folks said they would test it, but that was more
> > > > than a month ago.
> > > > 
> > > > It's not acceptable to let bug fixes rot for that long, I don't care
> > > > what their special internal testing procedure is.
> > > > 
> > > > If they give you further pushback, please just ignore them and apply
> > > > Eric's fix directly.
> > > > 
> > > > Thank you.
> > > 
> > > I imagine that this somehow got lost in the shuffle during the
> > > merge window.  That doesn't excuse it, of course.
> > > 
> > > It has waited long enough already, so I'll just go ahead and take it.
> > > 
> > it is my mistake to lost this patch during the iwlwifi re-factor work,
> > the patch is no longer apply and I ask Eric to rebase the patch.
> > 
> > Sorry again for the mistake
> 
> Well, it seems like a fix needed for 3.4.  And, the patch applies there.
> 
> It does cause some merge breakage in wireless-testing (and presumably
> in linux-next).  I'll attach the commit diff for the wireless-testing
> merge fixup I did, for review and/or as a peace offering to sfr... :-)
> 
> Please take a look at the result in wireless-testing and let me know
> if it is broken...thanks!
> 
Looks good to me, thanks very much for helping this.

Wey

> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
