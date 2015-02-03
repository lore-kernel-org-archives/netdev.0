From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] rhashtable: Add walk iterator primitives and use
 them in netlink
Date: Mon, 02 Feb 2015 19:19:34 -0800 (PST)
Message-ID: <20150202.191934.810788309905446440.davem@davemloft.net>
References: <20150127231950.GA11374@gondor.apana.org.au>
	<20150129.144246.1383921666389409323.davem@davemloft.net>
	<20150131031356.GA26781@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbbBCDTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:19:35 -0500
In-Reply-To: <20150131031356.GA26781@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 31 Jan 2015 14:13:56 +1100

> On Thu, Jan 29, 2015 at 02:42:46PM -0800, David Miller wrote:
>> 
>> I'm holding off on this series for now.
>> 
>> Let me know if you want me to do something different.
> 
> No problems.  Here is a new version of these two patches which
> hopefully should work on netfilter as well.
> 
> Note that the major functional difference compared to the previous
> one is that resizes are now handled properly and will cause the
> iterator to restart from scratch.
> 
> However, as with all existing hash table walker implementations,
> if you remove an element from the chain that we're walking over
> while we're waiting for user-space to give us a new buffer, then
> the walk may miss elements that are still on that chain.

Series applied to net-next.
