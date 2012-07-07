From: Ben Greear <greearb@candelatech.com>
Subject: Re: pre-fetching skb for delayed send
Date: Fri, 06 Jul 2012 21:15:29 -0700
Message-ID: <4FF7B7E1.4000602@candelatech.com>
References: <4FF77070.7040705@candelatech.com> <20120706235258.GD19462@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45048 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab2GGEPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 00:15:33 -0400
In-Reply-To: <20120706235258.GD19462@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/2012 04:52 PM, Benjamin LaHaise wrote:
> On Fri, Jul 06, 2012 at 04:10:40PM -0700, Ben Greear wrote:
>> So, is there an easy way to pre-fetch an skb and it's related pages?
>
> One trick would be to store the pointers to the skbs in an array rather than
> relying on a list of skbs.  That would enable you to issue prefetches for
> multiple skbs from a single cache line of the array, rather than relying
> upon the slow chasing of pointers guaranteed to cache miss in a list.

Well, to start with..I at least know the next skb to transmit,
so I figured I'd prefetch it before starting tx of the current
skb.

My question is more basic though:  Given an skb, how do you prefetch
it...do you just prefetch the skb pointer, or do you need to dig into
the guts of the skb?

Thanks,
Ben

>
> 		-ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
