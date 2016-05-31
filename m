From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] macvlan: Avoid unnecessary multicast cloning
Date: Tue, 31 May 2016 11:40:54 -0700 (PDT)
Message-ID: <20160531.114054.1989795898313360011.davem@davemloft.net>
References: <20160530081752.GA4956@gondor.apana.org.au>
	<20160530162759.GD8402@wantstofly.org>
	<20160531004945.GA11422@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbcEaSkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:40:55 -0400
In-Reply-To: <20160531004945.GA11422@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 31 May 2016 08:49:45 +0800

> On Mon, May 30, 2016 at 07:27:59PM +0300, Lennert Buytenhek wrote:
>>
>> That and stack switches to kworker threads and serialisation on
>> the bc_queue queue lock.
> 
> My patch should resolve these problems too since the packet is
> discarded if nobody is interested in it.

+1
