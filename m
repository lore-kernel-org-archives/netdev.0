From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Wed, 19 Mar 2014 23:52:17 -0400 (EDT)
Message-ID: <20140319.235217.1348886613951521818.davem@davemloft.net>
References: <20140318235811.0d8f230a@nehalam.linuxnetplumber.net>
	<20140319.135319.2039055704156238608.davem@davemloft.net>
	<20140319224442.GJ12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaCTDwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 23:52:19 -0400
In-Reply-To: <20140319224442.GJ12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 19 Mar 2014 23:44:42 +0100

> On Wed, Mar 19, 2014 at 01:53:19PM -0400, David Miller wrote:
>> Ok, the timer stuff could run from a workqueue just fine.
> 
> We have no-timer invocations, too, like addrconf_prefix_rcv. In that case the
> whole handling of the router advertisment should get deferred into the
> workqueue.

Just to be clear, you are saying that this doesn't need to be
synchronous?  Handling a prefix event seems like something that would
in fact need to be.
