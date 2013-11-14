From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] sit: link local routes are missing
Date: Thu, 14 Nov 2013 16:59:38 -0500 (EST)
Message-ID: <20131114.165938.1732224064334439971.davem@davemloft.net>
References: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
	<1384433467-4780-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab3KNV7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:59:40 -0500
In-Reply-To: <1384433467-4780-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 14 Nov 2013 13:51:06 +0100

> When a link local address was added to a sit interface, the corresponding route
> was not configured. This breaks routing protocols that use the link local
> address, like OSPFv3.
> 
> To ease the code reading, I remove sit_route_add(), which only adds v4 mapped
> routes, and add this kind of route directly in sit_add_v4_addrs(). Thus link
> local and v4 mapped routes are configured in the same place.
> 
> Reported-by: Li Hongjun <hongjun.li@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
