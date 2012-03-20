From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] ipv6: Allocate unique metrics for icmp6
 packets to prevent tainting dst metrics
Date: Tue, 20 Mar 2012 03:10:41 -0400 (EDT)
Message-ID: <20120320.031041.1349041584421003180.davem@davemloft.net>
References: <4F64CD4B.4070203@network-box.com>
	<20120319.180415.1274216814977167410.davem@davemloft.net>
	<1332222481.25418.540.camel@nbnickhq4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232Ab2CTHKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 03:10:49 -0400
In-Reply-To: <1332222481.25418.540.camel@nbnickhq4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Tue, 20 Mar 2012 13:48:01 +0800

> On Mon, 2012-03-19 at 18:04 -0400, David Miller wrote: 
>> Furthermore, callers are only ready to handle NULL vs. non-NULL as
>> return values from this function.  So this return value you are adding
>> will result in crashes.
> 
> This one I did check.  icmp6_dst_alloc returns error encoded pointers
> and all call sites test the return value with IS_ERR, I simply didn't
> understand the correct formatting macro, nor check the build properly.
> I think you got it mixed up with ip6_dst_alloc

Indeed you're right on this one.  We changed this recently, in fact.
