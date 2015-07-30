From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flow_dissector: remove
 __flow_hash_consistentify
Date: Thu, 30 Jul 2015 15:57:22 -0700 (PDT)
Message-ID: <20150730.155722.69727543232933153.davem@davemloft.net>
References: <1438202943-937619-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbbG3W5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 18:57:23 -0400
In-Reply-To: <1438202943-937619-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 29 Jul 2015 13:49:03 -0700

> The intent of this function was to produce a consistent hash for both
> directions of a flow. However, since we added more inputs to the flow
> hashing (IPv6 flow labels for instance) in a lot of cases we won't get
> the same hash computed for each direction anyway. Also, there is no
> defined correlation between the hashes computed in each direction of a
> flow.
> 
> This patch removes the function since it is not providing significant
> value and is expensive to be called for every packet. If there are
> ever users of the flow_hash_from_keys that did require consistency
> they can swap addresses and ports as needed in the flow_keys before
> calling flow_hash_from_keys.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

The conntrack issue needs to be sorted out before I can consider this
change seriously.
