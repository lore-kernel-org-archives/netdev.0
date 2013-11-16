From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] genetlink: reduce ops size and complexity (v2)
Date: Fri, 15 Nov 2013 20:53:13 -0500 (EST)
Message-ID: <20131115.205313.1543711974325231353.davem@davemloft.net>
References: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
	<20131114.171204.1979806323628158355.davem@davemloft.net>
	<1384521515.14295.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wimax@intel.com,
	bsingharora@gmail.com, netfilter-devel@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: johannes@sipsolutions.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384521515.14295.2.camel@jlt4.sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 15 Nov 2013 14:18:35 +0100

> We could instead register an array of pointers to the groups:
> 
> static const struct mcast_group *my_groups[] = {
> 	&my_foo_mcast_group,
> 	...
> };
> 
> and pass this to the family - that'd still be less space (one pointer
> for each group rather than two in a linked list) and still allow all
> groups and this array to be const, but it's not quite as big a
> saving ...
> 
> Thoughts?

This idea sounds fine.  I don't even thing the array indexing is
odd, especially if we can have named mnenomics for the indices
or similar.
