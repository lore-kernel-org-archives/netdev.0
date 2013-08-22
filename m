From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: ADSL/ATM linklayer tc shaping regression fix commits for stable
Date: Thu, 22 Aug 2013 10:04:26 +0200
Message-ID: <20130822100426.39be319d@redhat.com>
References: <20130820132629.51618797@redhat.com>
	<20130820151650.GA18016@kroah.com>
	<20130821140350.2b953007@redhat.com>
	<20130821.112023.744177612387539958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130821.112023.744177612387539958.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Aug 2013 11:20:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Wed, 21 Aug 2013 14:03:50 +0200
> 
> > 
> > On Tue, 20 Aug 2013 08:16:50 -0700
> > Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> >> On Tue, Aug 20, 2013 at 01:26:29PM +0200, Jesper Dangaard Brouer wrote:
> > [...]
> >  
> >> If there are issues with 3.10, that's a different story.
> >> 
> >> > Refactor improvements (v3.11-rc1):
> >> >  commit 130d3d68b52 (net_sched: psched_ratecfg_precompute() improvements)
> > 
> > Needed because it fixes the accuracy of the rate calc.
> > 
> >> > The linklayer ATM/ADSL fix, reached 3.11-rc6:
> >> >  commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
> > 
> > Needed because we broke userspace interface.
> > 
> >> David sends me the networking patches for the stable tree, and if he
> >> thinks these are applicable, then I'll take them.
> > 
> > DaveM, please?  What do you want me to do, submit this req/patches somehow?
> > 
> > (Can see that is not currently on your stable queue via:
> > http://patchwork.ozlabs.org/bundle/davem/stable/?state=*)
> 
> I'll put it there, you just have to formally ask me to do it that's
> all.

Thanks, I assume that this was formally enough and you are taking the patches.

So, for future reference:

Stable patches for the networking tree, I should:
1) check http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
   to see if my patch is already on your stable queue
2) if not, ask you and cc netdev@vger.kernel.org
3) you will handle the interaction with Greg and stable@vger.kernel.org

Correct?


> Asking Greg to do it directly is a complete waste of time. :-)

I'll remember that.  I was just following Documentation/stable_kernel_rules.txt,
I guess I should have known better as all my previous stable patches
have automagically been picked up and processed by you :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
