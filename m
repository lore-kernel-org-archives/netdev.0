From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: allow deffered probe of the driver
Date: Mon, 26 Jan 2015 17:10:16 -0800 (PST)
Message-ID: <20150126.171016.257852699853217898.davem@davemloft.net>
References: <1421947441.717.4.camel@uti.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: nicolae.rosia@certsign.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbA0BKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:10:18 -0500
In-Reply-To: <1421947441.717.4.camel@uti.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Date: Thu, 22 Jan 2015 17:31:05 +0000

> The driver is trying to acquire clocks which maybe
> are not available yet. Allow the driver to request
> deffered probe by providing a probe function and
> registering it with module_platform_driver. [1]
> This patch is based on 3.19-rc5.
> 
> [1] https://lkml.org/lkml/2013/9/23/118
> 
> Signed-off-by: Nicolae Rosia <nicolae.rosia@certsign.ro>

Applied.
