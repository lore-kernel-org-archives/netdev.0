From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH wireless-next 00/20] Use pr_<level>
Date: Fri, 15 Jun 2012 18:50:57 -0400
Message-ID: <20120615225057.GD7363@thunk.org>
References: <cover.1339739415.git.joe@perches.com>
 <1339745811.4512.0.camel@jlt3.sipsolutions.net>
 <1339757319.24527.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339757319.24527.21.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15, 2012 at 03:48:39AM -0700, Joe Perches wrote:
> To tee up conversions of:
> 	pr_<level>("%s: ...", ([truct netdevice *]foo)->name, ...)
> to
> 	netdev_<level>(foo, "...", ...) 

If the goal is to do the latter, why introduce needless patch churn
now just to get to pr_<level>?  Having a standardized netdev_<label>()
adds real benefit that can be weighed against the cost of code churn.
Why not just wait until the netdev_<level> infrastructure can be
introduced?  It will save effort on everybody's part.

	     	     	  	    		- Ted
