From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio_bus: don't return NULL from mdiobus_scan()
Date: Wed, 04 May 2016 16:14:44 -0400 (EDT)
Message-ID: <20160504.161444.466116308572489475.davem@davemloft.net>
References: <4702228.vWmKBZLz6G@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbcEDUOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:14:47 -0400
In-Reply-To: <4702228.vWmKBZLz6G@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 03 May 2016 23:14:41 +0300

> I've finally noticed that mdiobus_scan() also returns either NULL or error
> value on failure.  Return ERR_PTR(-ENODEV) instead of NULL since this is
> the  error value  already filtered out by the callers that want to ignore
> the  MDIO address scan failure...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
