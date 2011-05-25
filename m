From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] af-packet: Save reference to bound network device.
Date: Wed, 25 May 2011 18:42:37 -0400 (EDT)
Message-ID: <20110525.184237.257757281453830698.davem@davemloft.net>
References: <4DDD7D16.6030907@candelatech.com>
	<20110525.181418.1100603684033986711.davem@davemloft.net>
	<4DDD8487.6070000@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630Ab1EYWmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:42:43 -0400
In-Reply-To: <4DDD8487.6070000@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 25 May 2011 15:36:55 -0700

> I can't see where the code holds any reference to prot_hook.dev.
> (It just assigns the pointer and then does a dev_put()).
> 
> Maybe it gets away with it because a NETDEV_UNREGISTER event
> is always sent?

I think that is precisely the property it is depending upon.

It may seem sketchy, but as far as I can tell it's completely
legal.
