From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4_en: set number of rx rings used by RSS using
 ethtool
Date: Tue, 17 Jan 2012 12:25:37 -0500 (EST)
Message-ID: <20120117.122537.1430974467197123979.davem@davemloft.net>
References: <20120117.121841.1486682892503842786.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF4B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org,
	amirv@mellanox.co.il
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab2AQRZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:25:48 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF4B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 17 Jan 2012 17:22:18 -0000

>  
>> > +	/* RSS table size must be an order of 2 */
>> > +	if (rss_rings != (1 << order_base_2(rss_rings)))
>> > +		return -EINVAL;
>> 
>> This is an obscure way to make this kind of test.
>> 
>> The canonical way is:
>> 
>> 	if (is_power_of_2(rss_rings))
> 
> Which is probably (x & {x-1)) == 0

What is your point?  is_power_of_2() is the common helper function we
have in the kernel which makes that proper calculation.

And more importantly it has a meaningful name.

You make no contribution to this dicussion by saying how it may or
may not be implemented.

What makes it worse is that you didn't even bother to take the time to
check before making your statement.  This wastes everyone's time.
