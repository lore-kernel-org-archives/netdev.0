From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: potential out of bounds access in
 trie_show_stats()
Date: Wed, 24 Jul 2013 16:05:28 -0700 (PDT)
Message-ID: <20130724.160528.250036563854826098.davem@davemloft.net>
References: <1374519718-8299-1-git-send-email-jerry.snitselaar@oracle.com>
	<20130724150000.GB22402@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jerry.snitselaar@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130724150000.GB22402@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 24 Jul 2013 17:00:00 +0200

> On Mon, Jul 22, 2013 at 12:01:58PM -0700, Jerry Snitselaar wrote:
>> With the <= max condition in the for loop, it will be always go 1
>> element further than needed. If the condition for the while loop is
>> never met, then max is MAX_STAT_DEPTH, and for loop will walk off the
>> end of nodesizes[].
>> 
>> Signed-off-by: Jerry Snitselaar <jerry.snitselaar@oracle.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
