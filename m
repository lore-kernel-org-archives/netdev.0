From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to
 void
Date: Tue, 05 May 2015 19:20:03 -0400 (EDT)
Message-ID: <20150505.192003.2226565044238098170.davem@davemloft.net>
References: <cover.1430769294.git.joe@perches.com>
	<1430771550.2872.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbbEEXUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:20:05 -0400
In-Reply-To: <1430771550.2872.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 04 May 2015 13:32:30 -0700

> On Mon, 2015-05-04 at 13:05 -0700, Joe Perches wrote:
>> unsigned char * return values are sometimes awkward to work with.
>> Changing the return to void * is sometimes clearer.
>> 
>> The only uses of the return type is to do sets like
>>     *skb_puts(skb, 1) = char;
>>     
>> Adding another function specifically for that purpose allows the return
>> type to become void.
> 
> Obviously, this shouldn't be applied as-is.
> 
> It spans too many subsystems and can be done
> more incrementally.
> 
> Also, there are some missing conversions so
> this won't compile properly (sorry 'bout that)

I have no fundamental issues with this series once you fix up those
issues.
