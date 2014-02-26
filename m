From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory
 accounting for dgram sockets
Date: Wed, 26 Feb 2014 15:42:32 -0500 (EST)
Message-ID: <20140226.154232.1642777813885536970.davem@davemloft.net>
References: <20140219200811.GE1179@order.stressinduktion.org>
	<20140226.145559.1040609936875578841.davem@davemloft.net>
	<20140226202154.GA9626@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaBZUme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:42:34 -0500
In-Reply-To: <20140226202154.GA9626@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 26 Feb 2014 21:21:54 +0100

> On Wed, Feb 26, 2014 at 02:55:59PM -0500, David Miller wrote:
>> I think you can safely put the 'other' sock pointer into the control
>> block.  Because when we disassociate from a peer any pending packets
>> in flight to him will be consumed/dropped, so there can't be any
>> lingering references, right?
> 
> I am afraid lingering socket references will happen if the sockets are
> used in unconnected mode.

Sigh...

Ok, let's wait for your hackbench results and work from there.
