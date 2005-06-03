From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 12:02:57 -0700 (PDT)
Message-ID: <20050603.120257.21929814.davem@davemloft.net>
References: <42A0A25C.8000503@candelatech.com>
	<20050603.114950.119242486.davem@davemloft.net>
	<42A0A897.5080006@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, Robert.Olsson@data.slu.se, jdmason@us.ibm.com,
        shemminger@osdl.org, hadi@cyberus.ca, mitch.a.williams@intel.com,
        netdev@oss.sgi.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <42A0A897.5080006@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 03 Jun 2005 11:59:35 -0700

> David S. Miller wrote:
> > In a reply I just sent out to this thread, I postulate that the
> > jiffies check is hitting earlier with a lower weight value, a quick
> > look at /proc/net/softnet_stat during their testing will confirm or
> > deny this theory.
> 
> That would basically just decrease the work done in the NAPI poll though,
> so I don't see how that could be the problem, since the 'solution' was to
> force less work to be done.

It allows his application to get onto the CPU faster.
