From: David Miller <davem@davemloft.net>
Subject: Re: Can we replace the msleep(250) in dev.c netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 15:47:38 -0500 (EST)
Message-ID: <20130129.154738.2296526527975433560.davem@davemloft.net>
References: <51082FF3.4090805@candelatech.com>
	<20130129.153116.170658846017551064.davem@davemloft.net>
	<1359492330.30177.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3A2Urj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:47:39 -0500
In-Reply-To: <1359492330.30177.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Jan 2013 12:45:30 -0800

> On Tue, 2013-01-29 at 15:31 -0500, David Miller wrote:
>> If you only notice some time in the future that something has hung in
>> this state, the original message could be lost.  Therefore, I
>> definitely prefer that this thing keeps barking into the logs
>> periodically.
> 
> Not sure we need the full stack, as it probably contains no useful
> context / information at this point.

That's true.
