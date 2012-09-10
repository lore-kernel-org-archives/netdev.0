From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Take care of xfrm policy when checking dst
 entries
Date: Mon, 10 Sep 2012 13:18:29 -0400 (EDT)
Message-ID: <20120910.131829.193126565067890591.davem@davemloft.net>
References: <20120907.144828.97793990734588625.davem@davemloft.net>
	<1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
	<504DFA97.7070509@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab2IJRSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 13:18:39 -0400
In-Reply-To: <504DFA97.7070509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 10 Sep 2012 10:35:03 -0400

> I am not sure this is right...  This has a side-effect that when an
> rt_cache_flush() is called, it invalidates IPv6 routes a well....
> 
> Its all fine and good do this when a new policy is added, but not when
> IPv4 routing table changes.

I disagree.
