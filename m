From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: 03 Oct 2004 21:16:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096852582.1046.378.camel@jzny.localdomain>
References: <20041003213124.GG14344@postel.suug.ch>
	 <20041003213954.GI14344@postel.suug.ch>
	 <20041003161436.50293f9a.davem@davemloft.net>
	 <20041003233647.GN14344@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041003233647.GN14344@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-10-03 at 19:36, Thomas Graf wrote:
> * David S. Miller <20041003161436.50293f9a.davem@davemloft.net> 2004-10-03 16:14

> > > +#if (HZ%4) != 0
> > > +#error Bad HZ value.
> > > +#endif
> > 
> > This is going to fail to compile on a few platforms, namely m68knommu
> > and v850 which have configurations that result in using a HZ value
> > of 50 and 122 respectively.
> 
> This was taken over from net/sched/estimator.c so I guess there was no
> person ever using the rate estimator on such an arch ;)
> 
> Can we simply remove the check?

The granularity of the timing is dependent on this - 250msec increments.
Find a common demonitor for all Hz values which results in something
along 200ms range and we should be set. 

cheers,
jamal
