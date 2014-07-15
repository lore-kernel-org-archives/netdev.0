From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] Misc. fixes for iw_cxgb4
Date: Tue, 15 Jul 2014 16:25:41 -0700 (PDT)
Message-ID: <20140715.162541.2252769771295806367.davem@davemloft.net>
References: <1405353894-17495-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	roland@purestorage.com, swise@opengridcomputing.com,
	leedom@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaGOXZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:25:43 -0400
In-Reply-To: <1405353894-17495-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 14 Jul 2014 21:34:50 +0530

> This patch series adds support to determine ingress padding boundary at runtime.
> Advertise a larger max read queue depth for qps, and gather the resource limits
> from fw and use them to avoid exhausting all the resources and display TPTE on
> errors and add support for work request logging feature.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 and iw_cxgb4 driver.
> 
> Since this patch-series contains changes which are dependent on commit id
> fc5ab02 ("cxgb4: Replaced the backdoor mechanism to access the HW memory with
> PCIe Window method") we would like to request this patch series to get merged
> via David Miller's 'net-next' tree.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments. 
> 
> V2:
>  Optimized alloc_ird function, and several other changes related to debug prints
>  based on review comments given by Yann Droneaud.

Series applied to net-next, thanks.
