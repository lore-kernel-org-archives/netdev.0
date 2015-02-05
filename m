From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] rhashtable: Add iterators and use them
Date: Wed, 04 Feb 2015 20:35:53 -0800 (PST)
Message-ID: <20150204.203553.953032058529427740.davem@davemloft.net>
References: <20150202.192634.1792206005008667377.davem@davemloft.net>
	<20150203201750.GA22474@gondor.apana.org.au>
	<20150203203213.GA23177@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbBEEfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:35:54 -0500
In-Reply-To: <20150203203213.GA23177@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 4 Feb 2015 07:32:13 +1100

> On Wed, Feb 04, 2015 at 07:17:50AM +1100, Herbert Xu wrote:
>> 
>> > ERROR: "rhashtable_walk_start" [net/netfilter/nft_hash.ko] undefined!
>> 
>> Oops, I missed an export on that symbol.  I'll fix it up and
>> repost.
> 
> OK here is the repost without the hash_rnd patch.
> 
> The first patch fixes a potential crash with nft_hash destroying
> the table during a shrinking process.  While the next patch adds
> rhashtable iterators to replace current manual walks used by
> netlink and netfilter.  The final two patches make use of these
> iterators in netlink and netfilter.

Series applied to net-next.

Please address the sparse locking warnings reported against patch #3, it's
probably just some missing acquire/release annotations.
