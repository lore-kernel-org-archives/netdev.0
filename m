From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] drivers/net: Remove casts of void *
Date: Tue, 21 Jun 2011 15:50:36 -0700 (PDT)
Message-ID: <20110621.155036.1262228722432449059.davem@davemloft.net>
References: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
	<20110617.151903.1203335395245647912.davem@davemloft.net>
	<1308681934.3338.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756774Ab1FUWul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 18:50:41 -0400
In-Reply-To: <1308681934.3338.17.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 21 Jun 2011 11:45:34 -0700

> On Fri, 2011-06-17 at 15:19 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Thu, 16 Jun 2011 22:08:06 -0700
>> > Unnecessary casts of void * clutter the code.
>> > These are the remainder casts after several specific
>> > patches to remove netdev_priv and dev_priv.
>> > Done via coccinelle script (and a little editing):
>> Applied, thanks.
> 
> Unapplied?  I don't see this in net-next.

My bad, I have no idea how it disappeared.

I put it into net-next-2.6 and pushed it out, it should _really_
be there now.
