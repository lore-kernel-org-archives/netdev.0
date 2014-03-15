From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Replace u64_stats_fetch_begin_bh to
 u64_stats_fetch_begin_irq
Date: Fri, 14 Mar 2014 22:41:12 -0400 (EDT)
Message-ID: <20140314.224112.1327634842494982777.davem@davemloft.net>
References: <20140312212429.GA14893@electric-eye.fr.zoreil.com>
	<1394661695.21721.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<8738il4d8d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbaCOClO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 22:41:14 -0400
In-Reply-To: <8738il4d8d.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 13 Mar 2014 21:26:42 -0700

> Replace the bh safe variant with the hard irq safe variant.
> 
> We need a hard irq safe variant to deal with netpoll transmitting
> packets from hard irq context, and we need it in most if not all of
> the places using the bh safe variant.  
> 
> Except on 32bit uni-processor the code is exactly the same so don't
> bother with a bh variant, just have a hard irq safe variant that
> everyone can use.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

This looks great.

I'm going to apply this to the net-next tree, I hope the block folks
don't mind.
