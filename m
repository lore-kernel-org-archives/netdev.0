From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ethernet: ax88796: don't call free_irq
 without request_irq first
Date: Fri, 26 May 2017 14:57:52 -0400 (EDT)
Message-ID: <20170526.145752.1362583271442050963.davem@davemloft.net>
References: <20170525205453.21999-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        ben.dooks@codethink.co.uk
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933477AbdEZS57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:57:59 -0400
In-Reply-To: <20170525205453.21999-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Date: Thu, 25 May 2017 22:54:53 +0200

> The function ax_init_dev (which is called only from the driver's .probe
> function) calls free_irq in the error path without having requested the
> irq in the first place. So drop the free_irq call in the error path.
> 
> Fixes: 825a2ff1896e ("AX88796 network driver")
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Applied, thanks.
