From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Initialize RSS mode for all Ports
Date: Sat, 09 May 2015 16:33:37 -0400 (EDT)
Message-ID: <20150509.163337.2163809505484666683.davem@davemloft.net>
References: <1430921917-26206-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbEIUdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:33:43 -0400
In-Reply-To: <1430921917-26206-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  6 May 2015 19:48:37 +0530

> Implements t4_init_rss_mode() to initialize the rss_mode for all the ports. If
> Tunnel All Lookup isn't specified in the global RSS Configuration, then we need
> to specify a default Ingress Queue for any ingress packets which aren't hashed.
> We'll use our first ingress queue.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
