From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NAPI and CPU utilization [was: NAPI, e100, and system
 performance problem]
Date: Tue, 19 Apr 2005 14:09:51 -0700
Message-ID: <20050419140951.20965099.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<20050419113657.7290d26e.davem@davemloft.net>
	<Pine.LNX.4.61.0504191210040.15052@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gnb@sgi.com, hadi@cyberus.ca, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504191210040.15052@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please don't expect us to take the table of numbers seriously when it's
against a more than year old kernel and without a patch you know
and even explicitly mention makes this case perform significantly
better.

I understand your basic premise, but you're asking us to evaluate
known stale performance data.

Can you please get numbers against current 2.6.x kernels?

It is likely that people don't care so much about this because
on most systems the PIO overhead is not so pronounced as it is
on your enormous Altix systems.  On PCI-E and the onboard Intel
e1000 stuff, PIOs are incredibly cheap (Robert Olsson posted some
nice numbers not too long ago).

So what I'm saying is that the numbers probably don't fall much
this way on non-Altix systems.  But that doesn't mean we shouldn't
start using hw coalescing a little bit even with NAPI, I think
we should.
