From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: Remove unneeded use of
 IS_ERR_VALUE() macro
Date: Wed, 12 Aug 2015 16:50:06 -0700 (PDT)
Message-ID: <20150812.165006.368049193878368755.davem@davemloft.net>
References: <1439392223-28350-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Julia.Lawall@lip6.fr, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbHLXuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:50:07 -0400
In-Reply-To: <1439392223-28350-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 12 Aug 2015 12:10:23 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> There is no need to use the IS_ERR_VALUE() macro for checking
> the return value from pm_runtime_* functions.
> 
> Just do a simple negative test instead.
> 
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/pm_runtime.cocci.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
