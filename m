From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Tue, 14 Apr 2015 12:50:45 -0400 (EDT)
Message-ID: <20150414.125045.1736152567665368862.davem@davemloft.net>
References: <1428990724.6812.8.camel@googlemail.com>
	<20150413230714.2cf40794@urahara>
	<1428992320.6812.20.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, fw@strlen.de,
	eric.dumazet@gmail.com
To: sebastian.poehn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932967AbbDNQuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:50:50 -0400
In-Reply-To: <1428992320.6812.20.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Poehn <sebastian.poehn@gmail.com>
Date: Tue, 14 Apr 2015 08:18:40 +0200

> On Mon, 2015-04-13 at 23:07 -0700, Stephen Hemminger wrote:
>> On Tue, 14 Apr 2015 07:52:04 +0200
>> Sebastian Poehn <sebastian.poehn@gmail.com> wrote:
>> 
>> >  
>> > +	/* this should happen neither */
>> > +	if (unlikely(skb->sk))
>> > +		goto drop;
>> > +
>> 
>> With gcc, all goto's are already treated as unlikely().
> 
> Thanks for that recommendation. But before I re-cook: What about Clang
> and ICC?

I think even if this is the case with gcc, it's good documentation.
