From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make flow cache namespace-aware
Date: Thu, 15 Sep 2011 15:08:10 -0400 (EDT)
Message-ID: <20110915.150810.2078993779327513391.davem@davemloft.net>
References: <AANLkTinZJ9REmG0pHCVzEZ=tN-R4WuiQunuCBhmYtzyb@mail.gmail.com>
	<1314806727-5340-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, whydna@whydna.net
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934293Ab1IOTIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:08:20 -0400
In-Reply-To: <1314806727-5340-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Wed, 31 Aug 2011 12:05:27 -0400

> flow_cache_lookup will return a cached object (or null pointer) that the
> resolver (i.e. xfrm_policy_lookup) previously found for another namespace
> using the same key/family/dir.  Instead, make the namespace part of what
> identifies entries in the cache.
> 
> As before, flow_entry_valid will return 0 for entries where the namespace
> has been deleted, and they will be removed from the cache the next time
> flow_cache_gc_task is run.
> 
> Reported-by: Andrew Dickinson <whydna@whydna.net>
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied.
