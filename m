From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] stmmac: prevent probe drivers to crash kernel
Date: Tue, 27 Jan 2015 12:24:45 -0800 (PST)
Message-ID: <20150127.122445.923392803091632565.davem@davemloft.net>
References: <1422376683-30555-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbA0UYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:24:47 -0500
In-Reply-To: <1422376683-30555-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue, 27 Jan 2015 18:38:03 +0200

> In the case when alloc_netdev fails we return NULL to a caller. But there is no
> check for NULL in the probe drivers. This patch changes NULL to an error
> pointer. The function description is amended to reflect what we may get
> returned.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied, thank you.
