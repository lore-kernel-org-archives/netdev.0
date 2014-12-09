From: David Miller <davem@davemloft.net>
Subject: Re: is the commit 571dcfde2371 (net-next) a proper fix?
Date: Mon, 08 Dec 2014 19:35:32 -0500 (EST)
Message-ID: <20141208.193532.411317230886917624.davem@davemloft.net>
References: <1418034200.17201.45.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chenhc@lemote.com, peppe.cavallaro@st.com, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbaLIAff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 19:35:35 -0500
In-Reply-To: <1418034200.17201.45.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 08 Dec 2014 12:23:20 +0200

> It seems for me that commit 571dcfde2371 (stmmac: platform: fix default
> values of the filter bins setting) is redundant (moreover, it could be a
> cause of crash in some cases when there is no platform data defined in
> case of CONFIG_OF).
> 
> In case of no OF the platform data should be provided by platform code
> where the defaults are set. What did I miss?

You missed follow-up fix:

commit 28603d13997e2ef47f18589cc9a44553aad49c86
Author: Huacai Chen <chenhc@lemote.com>
Date:   Thu Nov 27 21:05:34 2014 +0800

    stmmac: platform: Move plat_dat checking earlier
