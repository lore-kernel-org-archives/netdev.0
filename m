From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] genetlink: reduce ops size and complexity (v2)
Date: Thu, 14 Nov 2013 17:12:04 -0500 (EST)
Message-ID: <20131114.171204.1979806323628158355.davem@davemloft.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
	<1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wimax@intel.com,
	bsingharora@gmail.com, netfilter-devel@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: johannes@sipsolutions.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 14 Nov 2013 17:14:38 +0100

> As before - reduce the complexity and data/code size of genetlink ops
> by making them an array rather than a linked list. Most users already
> use an array thanks to genl_register_family_with_ops(), so convert the
> remaining ones allowing us to get rid of the list head in each op.
> 
> Also make them const, this just makes sense at that point and the security
> people like making function pointers const as well :-)

I have to say, this is an absolutely fantastic space usage and
complexity improvement.

Applied, thanks a lot.
