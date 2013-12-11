From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] micrel: add support for KSZ8041RNLI
Date: Wed, 11 Dec 2013 13:58:41 -0500 (EST)
Message-ID: <20131211.135841.1810559740815410070.davem@davemloft.net>
References: <201312100220.42153.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab3LKTRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:17:12 -0500
In-Reply-To: <201312100220.42153.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 10 Dec 2013 02:20:41 +0300

> Renesas R-Car development boards use KSZ8041RNLI PHY which for some reason has
> ID of 0x00221537 that is not documented for KSZ8041-family PHYs and does not
> match the  documented ID of  0x0022151x (where 'x' is the revision).  We have
> to add the new #define PHY_ID_* and new ksphy_driver[] entry, almost the same
> as KSZ8041 one, differing only in the 'phy_id' and 'name' fields. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> This patch is atop of DaveM's 'net-next.git' repo.

Since this is just a simple device ID addition, I applied this to
'net', thanks.
