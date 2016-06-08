From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Reduce queue allocation to one in kdump
 kernel
Date: Wed, 08 Jun 2016 11:14:26 -0700 (PDT)
Message-ID: <20160608.111426.294601436242597914.davem@davemloft.net>
References: <1465389548-7651-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcFHSO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:14:28 -0400
In-Reply-To: <1465389548-7651-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  8 Jun 2016 18:09:08 +0530

> When in kdump kernel, reduce memory usage by only using a single Queue
> Set for multiqueue devices. So make netif_get_num_default_rss_queues()
> return one, when in kdump kernel.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
