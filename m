From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/5] bonding: enslave and locking bug fixes
Date: Fri, 19 Apr 2013 17:50:20 -0400 (EDT)
Message-ID: <20130419.175020.1724030185329877780.davem@davemloft.net>
References: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
	<15895.1366311486@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933294Ab3DSVuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:50:22 -0400
In-Reply-To: <15895.1366311486@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 18 Apr 2013 11:58:06 -0700

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>>Hi,
>>This patch-set fixes mainly bugs on enslave failure and one occasion
>>of a needed locking. The patches are:
>>
>>	1. On enslave failure mc addresses are not flushed from the slave
>>	2. On enslave failure vlans are not cleaned up from the slave
>>	3. On enslave failure the bond's primary and curr_active_slave
>>	   are not cleaned up (which might result in use of freed memory)
>>	4. On enslave failure netpoll is not disabled which might result in
>>	   a memory leak
>>	5. In bond_mc_swap() the bond's mc addr list is walked without
>>	   netif_addr_lock, since it can be called without rtnl, add it
>>
>>v2: patch 01 - fix log message and remove unnecessary code move
> 
> 	All look good to me.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Series applied, thanks everyone.
