From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: add support for skb->xmit_more
Date: Fri, 17 Oct 2014 23:47:43 -0400 (EDT)
Message-ID: <20141017.234743.475679360135422258.davem@davemloft.net>
References: <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
	<543FF408.3000808@solarflare.com>
	<alpine.LFD.2.03.1410171512070.3218@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rstonehouse@solarflare.com, dborkman@redhat.com,
	nikolay@redhat.com, netdev@vger.kernel.org, sshah@solarflare.com,
	jcooper@solarflare.com, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaJRDrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:47:45 -0400
In-Reply-To: <alpine.LFD.2.03.1410171512070.3218@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 17 Oct 2014 15:32:25 +0100

> Don't ring the doorbell, and don't do PIO.  This will also prevent
>  TX Push, because there will be more than one buffer waiting when
>  the doorbell is rung.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
