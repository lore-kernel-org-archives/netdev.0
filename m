From: David Miller <davem@davemloft.net>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are
 never invalidated
Date: Fri, 19 Oct 2012 16:07:11 -0400 (EDT)
Message-ID: <20121019.160711.1159467896676133280.davem@davemloft.net>
References: <20121019195557.GG17417@1wt.eu>
	<20121019.160104.115897882147794932.davem@davemloft.net>
	<20121019200318.GH17417@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, stable@vger.kernel.org, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab2JSUHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 16:07:13 -0400
In-Reply-To: <20121019200318.GH17417@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 19 Oct 2012 22:03:18 +0200

> On Fri, Oct 19, 2012 at 04:01:04PM -0400, David Miller wrote:
>> From: Willy Tarreau <w@1wt.eu>
>> Date: Fri, 19 Oct 2012 21:55:57 +0200
>> 
>> > On Fri, Oct 19, 2012 at 03:49:30PM -0400, David Miller wrote:
>> >> 
>> >> How about checking if these changes are already in 3.0/3.2/etc. or not
>> >> before asking such questions?
>> > 
>> > Because I didn't find the patches in 3.0 and Ben said he backported them
>> > from 3.6, I think these are two valid reasons to ask, no ?
>> 
>> Well, the thing is, I personally don't consider them appropriate for
>> 3.x.y -stable backports, and that's why I haven't submitted them.
> 
> OK. Is is because the issue is less important there or because the fix are
> more risky than the issues they fix (or any other reason) ?

I have a different opinion about the risk/benefit ratio than Ben does.

I do not think these cases are important enough to enough people to
justify -stable inclusion at all.
