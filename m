From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v5] lib/rhashtable: allow user to set the
 minimum shifts of shrinking
Date: Wed, 3 Sep 2014 18:18:52 +0100
Message-ID: <20140903171852.GA31628@casper.infradead.org>
References: <1409707356-3795-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41265 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbaICRSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 13:18:54 -0400
Content-Disposition: inline
In-Reply-To: <1409707356-3795-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/14 at 09:22am, Ying Xue wrote:
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

Thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>
