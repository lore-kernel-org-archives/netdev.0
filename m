From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] at86rf230: add irq type configuration option
Date: Fri, 12 Apr 2013 18:20:53 -0400 (EDT)
Message-ID: <20130412.182053.1145964817189847292.davem@davemloft.net>
References: <cover.1365716125.git.sascha@ps.nvbi.de>
	<cover.1365716125.git.sascha@ps.nvbi.de>
	<031f12b1d0449ffb6fe43dfd6b136369581cae4c.1365716125.git.sascha@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: sascha@ps.nvbi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab3DLWU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 18:20:58 -0400
In-Reply-To: <031f12b1d0449ffb6fe43dfd6b136369581cae4c.1365716125.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Herrmann <sascha@ps.nvbi.de>
Date: Fri, 12 Apr 2013 00:16:13 +0200

>  static int at86rf230_hw_init(struct at86rf230_local *lp)
>  {
>  	u8 status;
> -	int rc;
> +	int rc, irq_pol;
> +	struct at86rf230_platform_data *pdata = lp->spi->dev.platform_data;

Please order local variable declarations from longest line to
shortest line, not the other way around.

Thanks.
