From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: optimize neigh_parms_release()
Date: Wed, 29 Oct 2014 16:12:11 -0400 (EDT)
Message-ID: <20141029.161211.1100245948317543289.davem@davemloft.net>
References: <1414607371-4246-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757067AbaJ2UMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 16:12:13 -0400
In-Reply-To: <1414607371-4246-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 29 Oct 2014 19:29:31 +0100

> In neigh_parms_release() we loop over all entries to find the entry given in
> argument and being able to remove it from the list. By using a double linked
> list, we can avoid this loop.
> 
> Here are some numbers with 30 000 dummy interfaces configured:
> 
> Before the patch:
> $ time rmmod dummy
> real	2m0.118s
> user	0m0.000s
> sys	1m50.048s
> 
> After the patch:
> $ time rmmod dummy
> real	1m9.970s
> user	0m0.000s
> sys	0m47.976s
> 
> Suggested-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks great, applied, thanks Nicolas.
