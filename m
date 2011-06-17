From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: tidyup compile warrning
Date: Thu, 16 Jun 2011 23:08:37 -0400 (EDT)
Message-ID: <20110616.230837.2097042603976967927.davem@davemloft.net>
References: <w3p62oa6t8a.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: morimoto.kuninori@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836Ab1FQDIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:08:42 -0400
In-Reply-To: <w3p62oa6t8a.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kuninori Morimoto <morimoto.kuninori@renesas.com>
Date: Mon, 13 Jun 2011 17:17:09 +0900

> This patch tidyup below warrning
> 
> ${LINUX}/drivers/net/sh_eth.c:1773: warning:
> 'mdp' may be used uninitialized in this function
> 
> Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Kuninori Morimoto <morimoto.kuninori@renesas.com>

Please just move the mdp assignment right after alloc_netdev()
succeeds.
