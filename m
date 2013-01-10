From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: use addrconf_get_prefix_route for prefix
 route lookup [v2]
Date: Thu, 10 Jan 2013 14:39:21 -0800 (PST)
Message-ID: <20130110.143921.1060148433440698446.davem@davemloft.net>
References: <50ED88AF.3040705@6wind.com>
	<683E9BA1-C85B-43E0-AF98-397D50E302F6@ipflavors.com>
	<50EE8D79.1080807@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r.kuntz@ipflavors.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab3AJWjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:39:22 -0500
In-Reply-To: <50EE8D79.1080807@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Jan 2013 18:44:25 +0900

> Romain KUNTZ wrote:
> 
>> From 203474c87f45da40b5c9d9e629164561307b4199 Mon Sep 17 00:00:00 2001
>> From: Romain Kuntz <r.kuntz@ipflavors.com>
>> Date: Thu, 10 Jan 2013 07:41:36 +0100
>> Subject: [PATCH 1/1] ipv6: use addrconf_get_prefix_route for prefix route lookup [v2]
>> 
>> Replace ip6_route_lookup() with addrconf_get_prefix_route() when
>> looking up for a prefix route. This ensures that the connected prefix
>> is looked up in the main table, and avoids the selection of other
>> matching routes located in different tables as well as blackhole
>> or prohibited entries.
>> 
>> In addition, this fixes an Opps introduced by commit 64c6d08e (ipv6:
>> del unreachable route when an addr is deleted on lo), that would occur
>> when a blackhole or prohibited entry is selected by ip6_route_lookup().
>> Such entries have a NULL rt6i_table argument, which is accessed by
>> __ip6_del_rt() when trying to lock rt6i_table->tb6_lock.
>> 
>> The function addrconf_is_prefix_route() is not used anymore and is
>> removed.
>> 
>> [v2] Minor indentation cleanup and log updates.
>> 
>> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
>> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
 ...
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 

Applied.
