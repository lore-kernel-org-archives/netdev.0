From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: fix sparse warnings
Date: Thu, 06 Nov 2014 14:35:38 -0500 (EST)
Message-ID: <20141106.143538.548139779010792028.davem@davemloft.net>
References: <1415180732-8011-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbaKFTfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:35:41 -0500
In-Reply-To: <1415180732-8011-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed,  5 Nov 2014 11:45:32 +0200

> This patch fixes the following sparse warnings.
> 
> drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol 'enh_desc_ops' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning: symbol 'ndesc_ops' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning: symbol 'stmmac_ptp' was not declared. Should it be static?
> 
> There is no functional change.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Acked-by: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> ---
> Since v1:
> - redone as Giuseppe suggested

Applied, thanks.
