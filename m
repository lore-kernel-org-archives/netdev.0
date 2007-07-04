From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Re: [NETPOLL] netconsole: fix soft lockup when removing module
Date: Wed, 4 Jul 2007 08:41:59 +0200
Message-ID: <20070704064159.GA2057@ff.dom.local>
References: <20070701173558.GA207@tv-sign.ru> <20070702075226.GB1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758968AbXGDGdp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070702075226.GB1639@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 09:52:26AM +0200, Jarek Poplawski wrote:
> 
> From my recent patch:
> 
> > >    #1
> > >    Until kernel ver. 2.6.21 (including) cancel_rearming_delayed_work()
> > >    required a work function should always (unconditionally) rearm with
> > >    delay > 0 - otherwise it would endlessly loop. This patch replaces
> > >    this function with cancel_delayed_work(). Later kernel versions don't
> > >    require this, so here it's only for uniformity.
> 
> But Oleg Nesterov <oleg@tv-sign.ru> found:
> 
> > But 2.6.22 doesn't need this change, why it was merged?
> > 
> > In fact, I suspect this change adds a race,
> ...
> 
> His description was right (thanks), so this patch reverts #1.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Oleg,

I think maybe you could ack these 2 netconsole patches...
They were done on your request but it looks like Andrew
is waiting on something...

Thanks,
Jarek P.
