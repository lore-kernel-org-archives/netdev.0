From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] rhashtable: Avoid calculating hash again
 to unlock
Date: Mon, 16 Mar 2015 17:15:00 -0400 (EDT)
Message-ID: <20150316.171500.2219680403539914280.davem@davemloft.net>
References: <e66c2872d3182c2df12f5657903f19e8ffc1f0f0.1426494808.git.tgraf@suug.ch>
	<20150316.162202.2166849044626317059.davem@davemloft.net>
	<20150316204836.GA6534@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932779AbbCPVPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 17:15:03 -0400
In-Reply-To: <20150316204836.GA6534@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 17 Mar 2015 07:48:36 +1100

> On Mon, Mar 16, 2015 at 04:22:02PM -0400, David Miller wrote:
>> From: Thomas Graf <tgraf@suug.ch>
>> Date: Mon, 16 Mar 2015 10:42:26 +0100
>> 
>> > Caching the lock pointer avoids having to hash on the object
>> > again to unlock the bucket locks.
>> > 
>> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
>> 
>> I'd like to hold off on this.
>> 
>> My understanding is that Herbert plans to expand the table size
>> synchonously during insert in emergency situations, and in that regime
>> some of these optimization won't be valid.
> 
> Actually this patch does not conflict with my multiple rehashing
> work (the final scheme I used only requires two locks) so please
> feel free to merge it and I will rebase my stuff.

Ok, done, thanks.
