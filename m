From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/5] perf: net_dropmonitor: Make it work and make it fast
Date: Tue, 21 May 2013 09:33:56 -0400
Message-ID: <20130521133355.GA3613@neilslaptop.think-freely.org>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 01:42:56AM +0100, Ben Hutchings wrote:
> Somewhat surprisingly, the net_dropmonitor reporting script doesn't work
> at all.  This series fixes it and then makes it slightly more efficient.
> 
> Ben.
> 
It worked fine when I first submitted it.  I wonder if there was a paramter
order change at some point that I wasn't CC'ed on.

Either way, this all looks good.  Thanks Ben.

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> Ben Hutchings (5):
>   perf: net_dropmonitor: Fix trace parameter order
>   perf: net_dropmonitor: Fix symbol-relative addresses
>   perf: net_dropmonitor: Do not assume ordering of dictionaries
>   perf: net_dropmonitor: Use bisection in symbol lookup
>   perf: net_dropmonitor: Remove progress indicator
> 
>  tools/perf/scripts/python/net_dropmonitor.py |   39 ++++++++++++++------------
>  1 file changed, 21 insertions(+), 18 deletions(-)
> 
> 
