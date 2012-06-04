From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove casts to same type
Date: Mon, 04 Jun 2012 11:53:18 -0400 (EDT)
Message-ID: <20120604.115318.1282381440585171166.davem@davemloft.net>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
	<20120604.114533.1720204611284591292.davem@davemloft.net>
	<1338825128.8574.15.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433Ab2FDPxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:53:20 -0400
In-Reply-To: <1338825128.8574.15.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 04 Jun 2012 08:52:08 -0700

> On Mon, 2012-06-04 at 11:45 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> > Adding casts of objects to the same type is unnecessary
>> > and confusing for a human reader.
> []
>> > I used the coccinelle script below to find and remove these
>> > unnecessary casts.  I manually removed the conversions this
>> > script produces of casts with __force and __user.
>> > 
>> > @@
>> > type T;
>> > T *p;
>> > @@
>> > 
>> > -	(T *)p
>> > +	p
>> Applied to net-next, thanks Joe.
> 
> Do you want the same thing for drivers/net?
> 
> It's pretty big and might be better broken into
> commits by maintainer/directory.

I don't see any value beyond perhaps splitting it into
drivers/net/ethernet, drivers/net/wireless, and "rest".
