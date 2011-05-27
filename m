From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: Kill ratelimit.h dependency in linux/net.h
Date: Thu, 26 May 2011 22:40:32 -0400 (EDT)
Message-ID: <20110526.224032.16512234674774492.davem@davemloft.net>
References: <20110526.164330.2076981043593394399.davem@davemloft.net>
	<1306445044.25717.0.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349Ab1E0Cks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 22:40:48 -0400
In-Reply-To: <1306445044.25717.0.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 26 May 2011 14:24:04 -0700

> On Thu, 2011-05-26 at 16:43 -0400, David Miller wrote:
>> Ingo Molnar noticed that we have this unnecessary ratelimit.h
>> dependency in linux/net.h, which hid compilation problems from
>> people doing builds only with CONFIG_NET enabled.
>> 
>> Move this stuff out to a seperate net/net_ratelimit.h file and
>> include that in the only two places where this thing is needed.
> 
> git add net/net_ratelimit.h?

Good catch :-)  It's contents are essentially what were being
deleted from linux/net.h :-)
