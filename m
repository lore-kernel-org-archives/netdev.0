From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Sat, 7 Nov 2015 19:21:04 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1511071920450.1976@localhost6.localdomain6>
References: <alpine.DEB.2.02.1511052107501.2065@localhost6.localdomain6> <20151105.151320.1646543343654766675.davem@davemloft.net> <alpine.DEB.2.10.1511061142440.2378@hadrien> <20151107.131834.2152455608881468661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151107.131834.2152455608881468661.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 7 Nov 2015, David Miller wrote:

> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Fri, 6 Nov 2015 11:57:34 +0100 (CET)
> 
> >> > Would it be preferable to remove the macro entirely and inline the for
> >> > loop header?
> >>
> >> Could you show me an example of how this would look exactly?
> > 
> > One possible solution is below.  I moved the initialization of the nh
> > pointer inside the loop to reduce the size of the loop header.  One could
> > also inline fi->fib_nh[nhsel] where it occurs, but it seemed that that
> > would make quite long expressions.
> 
> Personally I like the explicit named iterator.  It is descriptive and
> tells that we are walking over all of the nexthops for a route.

OK, I'll follow that solution.

julia
