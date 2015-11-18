From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fm10k: fix memory leak
Date: Wed, 18 Nov 2015 15:06:12 -0500 (EST)
Message-ID: <20151118.150612.1789333569072309866.davem@davemloft.net>
References: <20151117142427.37a4cc36@samsung9>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443AbbKRUGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:06:14 -0500
In-Reply-To: <20151117142427.37a4cc36@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Tue, 17 Nov 2015 14:24:27 -0800

> This was detected by Coverity.
> The function skb_cow_head leaves skb alone on failure, so caller needs
> to free.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
