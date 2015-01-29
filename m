From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] rhashtable: Add walk iterator primitives and use
 them in netlink
Date: Thu, 29 Jan 2015 14:42:46 -0800 (PST)
Message-ID: <20150129.144246.1383921666389409323.davem@davemloft.net>
References: <20150122084924.GA4720@gondor.apana.org.au>
	<20150125232040.GA17936@gondor.apana.org.au>
	<20150127231950.GA11374@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbbA2Wmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:42:47 -0500
In-Reply-To: <20150127231950.GA11374@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jan 2015 10:19:50 +1100

> On Mon, Jan 26, 2015 at 10:20:40AM +1100, Herbert Xu wrote:
>> 
>> Here are the first two patches, one to add the primitives and one
>> to demonstrate its use in netlink.  In fact while testing this I
>> found that the existing netlink walking code is totally broken.
> 
> So this is a repost of the same thing.  These lockless iterators
> won't be usable by netfilter as it stands because it wants to do
> nested walks and also isn't currently lockless.
> 
> However, I'll wait for Patrick to post his pending patches to see
> what exactly he needs before implementing helpers for that case.

I'm holding off on this series for now.

Let me know if you want me to do something different.

Thanks.
