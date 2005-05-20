From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 20 May 2005 15:33:26 -0700 (PDT)
Message-ID: <20050520.153326.08322399.davem@davemloft.net>
References: <1116031159.6214.8.camel@rh4>
	<20050513.222007.78719997.davem@davemloft.net>
	<Pine.LNX.4.61.0505201442380.11419@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0505201442380.11419@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arthur Kepner <akepner@sgi.com>
Date: Fri, 20 May 2005 14:52:35 -0700 (PDT)

> When the default coalescence parameters are used (rx-frames, 
> rx-frames-irq both set to 5) the maximum number of received 
> packets per interrupt is ~4.2. Setting rx-frames and 
> rx-frames-irq to 20 caused the maximum number of received
> packets per interrupt to rise to ~19.6. Maximum CPU 
> utilization went down from ~52% to ~35%. Very nice.

Yes, but using such a high value makes latency go into the
toilet. :-)

I'd much rather see dynamic settings based upon packet rate.
It's easy to resurrect the ancient code from the early
tg3 days which does this.

Thanks for all your testing, it is very informative and
useful.
