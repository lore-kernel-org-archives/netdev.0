From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Fix parameter order of hlist_add_behind
Date: Sat, 16 Aug 2014 19:19:51 -0700 (PDT)
Message-ID: <20140816.191951.1131268812372725722.davem@davemloft.net>
References: <1408090779-5020-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbaHQCTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 22:19:35 -0400
In-Reply-To: <1408090779-5020-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Fri, 15 Aug 2014 10:19:39 +0200

> 1d023284c31a4e40a94d5bbcb7dbb7a35ee0bcbc ("list: fix order of arguments for
> hlist_add_after(_rcu)") was incorrectly rebased on top of
> d9124268d84a836f14a6ead54ff9d8eee4c43be5 ("batman-adv: Fix out-of-order
> fragmentation support"). The parameter order change of the rebased patch was
> not re-applied as expected. This causes a memory leak and can cause crashes
> when out-of-order packets are received. hlist_add_behind will try to access the
> uninitalized list pointers of frag_entry_new to find the previous/next entry
> and may modify/read random memory locations.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Applied, thank you.
