From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/1] drivers: net: cpsw: add support to
 show hw stats via ethtool
Date: Wed, 24 Jul 2013 17:52:56 -0700 (PDT)
Message-ID: <20130724.175256.27980970277643257.davem@davemloft.net>
References: <1374574097-26188-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3GYAw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:52:57 -0400
In-Reply-To: <1374574097-26188-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 23 Jul 2013 15:38:17 +0530

> Add support to show CPSW hardware statistics to user via ethtool
> so user can find if there were any error reported by hardware or
> the system is over loaded duing high data rate transfer.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
> Changes from initial version
> * Change hw_stats variable from struct cpsw_hw_stats __iomem * to u8 __iomem *,
>   so that accessing hw_stats doesn't require type casting.

This looks a lot better, applied, thanks.
