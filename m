From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ipv6: Fix inet6_init() cleanup order
Date: Mon, 18 Nov 2013 15:39:58 -0500 (EST)
Message-ID: <20131118.153958.330107124104494149.davem@davemloft.net>
References: <1384633044-26453-1-git-send-email-vyasevich@gmail.com>
	<20131116202646.GE16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, lorenzo@google.com,
	fabio.estevam@freescale.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab3KRUkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 15:40:01 -0500
In-Reply-To: <20131116202646.GE16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 16 Nov 2013 21:26:46 +0100

> On Sat, Nov 16, 2013 at 03:17:24PM -0500, Vlad Yasevich wrote:
>> Commit 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
>> 	net: ipv6: Add IPv6 support to the ping socket
>> 
>> introduced a change in the cleanup logic of inet6_init and
>> has a bug in that ipv6_packet_cleanup() may not be called.
>> Fix the cleanup ordering.
>> 
>> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> CC: Lorenzo Colitti <lorenzo@google.com>
>> CC: Fabio Estevam <fabio.estevam@freescale.com>
>> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks great, thanks for sorting this out properly.

I'll queue this up for -stable as well.

Thanks again!
