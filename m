From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: push partner queue for skb->xmit_more
Date: Mon, 02 Nov 2015 23:03:52 -0500 (EST)
Message-ID: <20151102.230352.950957445475330532.davem@davemloft.net>
References: <56375C53.6010006@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: mhabets@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbbKCEDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 23:03:54 -0500
In-Reply-To: <56375C53.6010006@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Habets <mhabets@solarflare.com>
Date: Mon, 2 Nov 2015 12:51:31 +0000

> When the IP stack passes SKBs the sfc driver puts them in 2 different TX
> queues (called partners), one for checksummed and one for not checksummed.
> If the SKB has xmit_more set the driver will delay pushing the work to the
> NIC.
> 
> When later it does decide to push the buffers this patch ensures it also
> pushes the partner queue, if that also has any delayed work. Before this
> fix the work in the partner queue would be left for a long time and cause
> a netdev watchdog.
> 
> Fixes: 70b33fb ("sfc: add support for skb->xmit_more")
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Martin Habets <mhabets@solarflare.com>

Please do not separate the Fixes: tag from the other tags with an
empty line.  They should all solidly be together in an uninterrupted
block of text.

Applied and queued up for -stable.
