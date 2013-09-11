From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: Move skb_clone check closer to call
Date: Wed, 11 Sep 2013 16:04:03 -0400 (EDT)
Message-ID: <20130911.160403.1705666845363451822.davem@davemloft.net>
References: <20130907022711.GA22613@gondor.apana.org.au>
	<20130910013810.GA28966@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103Ab3IKUEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:04:05 -0400
In-Reply-To: <20130910013810.GA28966@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 10 Sep 2013 10:38:10 +0900

> On Sat, Sep 07, 2013 at 12:27:11PM +1000, Herbert Xu wrote:
>> Currently macvlan calls skb_clone in macvlan_broadcast but checks
>> for a NULL return in macvlan_broadcast_one instead.  This is
>> needlessly confusing and may lead to bugs introduced later.
>> 
>> This patch moves the error check to where the skb_clone call is.
>> 
>> The only other caller of macvlan_broadcast_one never passes in a
>> NULL value so it doesn't need the check either.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> This seems good to me as macvlan_handle_frame(), which is
> the only other caller of macvlan_broadcast_one(), already checks
> that skb is non-NULL before calling macvlan_handle_frame().
> 
> Reviewed-by: Simon Horman <horms@verge.net.au>

Applied, thanks everyone.
