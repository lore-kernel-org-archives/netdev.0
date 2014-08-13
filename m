From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: fix return value in tg3_get_stats64
Date: Wed, 13 Aug 2014 16:17:34 -0700 (PDT)
Message-ID: <20140813.161734.2107510820154608070.davem@davemloft.net>
References: <1407915296-12692-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbaHMXRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 19:17:35 -0400
In-Reply-To: <1407915296-12692-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 13 Aug 2014 13:04:56 +0530

> When tp->hw_stats is 0, tg3_get_stats64 should display previously
> recorded stats. So it returns &tp->net_stats_prev. But the caller,
> dev_get_stats, ignores the return value.
> 
> Fix this by assigning tp->net_stats_prev to stats and returning stats.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, but please target 'net' for bug fixes in the future.

Thanks.
