From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event
 via rtnetlink
Date: Wed, 05 Dec 2012 12:54:53 -0500 (EST)
Message-ID: <20121205.125453.1457654258131828976.davem@davemloft.net>
References: <50BE56D3.2030704@6wind.com>
	<50BF29DA.7020903@6wind.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2LERyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 12:54:54 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Wed, 5 Dec 2012 11:41:33 -0000

> Probably worth commenting that the 64bit items might only be 32bit aligned.
> Just to stop anyone trying to read/write them with pointer casts.

Rather, let's not create this situation at all.

It's totally inappropriate to have special code to handle every single
time we want to put 64-bit values into netlink messages.

We need a real solution to this issue.
