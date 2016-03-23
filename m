From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 13:40:13 -0400 (EDT)
Message-ID: <20160323.134013.938048330786929104.davem@davemloft.net>
References: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	u.kleine-koenig@pengutronix.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453AbcCWRkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:40:19 -0400
In-Reply-To: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 23 Mar 2016 00:44:40 +0300

> The driver of course "knows" that the chip's reset signal is active low,
> so  it drives the GPIO to 0  to reset the PHY and to 1 otherwise; however
> all this will only work iff the GPIO  is  specified as active-high in the
> device tree!  I think both the driver and the device trees (if there are
> any -- I was unable to find them) need to be fixed in this case...
> 
> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
