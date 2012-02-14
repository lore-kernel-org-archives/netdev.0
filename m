From: David Miller <davem@davemloft.net>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 14:43:35 -0500 (EST)
Message-ID: <20120214.144335.558771219791311889.davem@davemloft.net>
References: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<201202141350.57657.jdelvare@suse.de>
	<20120214133418.GJ32155@v3-1054>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, eric.dumazet@gmail.com, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab2BNTui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:50:38 -0500
In-Reply-To: <20120214133418.GJ32155@v3-1054>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Date: Tue, 14 Feb 2012 14:34:18 +0100

> On Tue, Feb 14, 2012 at 01:50:57PM +0100, Jean Delvare wrote:
>> 
>> > We could have a 5 sec timer in case device is a slave.
>> > 
>> > diff --git a/drivers/net/ethernet/3com/3c59x.c
>> >  b/drivers/net/ethernet/3com/3c59x.c index 1282f04..e463d10 100644
>> > --- a/drivers/net/ethernet/3com/3c59x.c
>> > +++ b/drivers/net/ethernet/3com/3c59x.c
>> > @@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
>> >  		ok = 1;
>> >  	}
>> > 
>> > -	if (!netif_carrier_ok(dev))
>> > +	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
>> >  		next_tick = 5*HZ;
>> > 
>> >  	if (vp->medialock)
>> 
>> Yes I think this makes a lot of sense. If you send this upstream you can 
>> add:
>> 
>> Acked-by: Jean Delvare <jdelvare@suse.de>
>> 
> 
> I'm fine with this too.

Eric, please submit this formally.
