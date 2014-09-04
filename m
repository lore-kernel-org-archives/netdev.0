From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] lib/rhashtable: allow user to set the
 minimum shifts of shrinking
Date: Wed, 03 Sep 2014 20:57:03 -0700 (PDT)
Message-ID: <20140903.205703.1720919253022709961.davem@davemloft.net>
References: <1409707356-3795-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaIDD4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:56:01 -0400
In-Reply-To: <1409707356-3795-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 3 Sep 2014 09:22:36 +0800

> Although rhashtable library allows user to specify a quiet big size
> for user's created hash table, the table may be shrunk to a
> very small size - HASH_MIN_SIZE(4) after object is removed from
> the table at the first time. Subsequently, even if the total amount
> of objects saved in the table is quite lower than user's initial
> setting in a long time, the hash table size is still dynamically
> adjusted by rhashtable_shrink() or rhashtable_expand() each time
> object is inserted or removed from the table. However, as
> synchronize_rcu() has to be called when table is shrunk or
> expanded by the two functions, we should permit user to set the
> minimum table size through configuring the minimum number of shifts
> according to user specific requirement, avoiding these expensive
> actions of shrinking or expanding because of calling synchronize_rcu().
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thank you.
