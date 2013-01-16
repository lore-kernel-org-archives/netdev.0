From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Wed, 16 Jan 2013 16:31:03 -0500 (EST)
Message-ID: <20130116.163103.2220017883581085962.davem@davemloft.net>
References: <1358367562-1697-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab3APVbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:31:06 -0500
In-Reply-To: <1358367562-1697-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 17 Jan 2013 01:49:22 +0530

> +	/*
> +	 * If there is no more tx desc left free then we need to
> +	 * tell the kernel to stop sending us tx frames.
> +	 */

Please format multi-line comments:

	/* Like
	 * this.
	 */

in the networking.

Thanks.
