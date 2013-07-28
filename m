From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 06:44:46 -0400
Message-ID: <20130728104446.GB9876@neilslaptop.think-freely.org>
References: <87k3kbdcmy.fsf@canonical.com>
 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
 <1374969583.3669.23.camel@edumazet-glaptop>
 <20130727.200205.67471633133830510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130727.200205.67471633133830510.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 27, 2013 at 08:02:05PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 27 Jul 2013 16:59:43 -0700
> 
> > If a hardware needs frame being in a single 4K page, its driver must do
> > its own allocation, or add appropriate aligning logic.
> 
> Whatever the cause the original patch in this thread is not the
> correct fix and I've thus reverted it.
> 

So what exactly is the consensus here?  We can certainly modify the patch to
ensure allocation on a 4k boundary, and within a unique 4k page, but thats just
a guess at the problem, and the Qualcomm people have been silent on the issue
for weeks now.

Neil
