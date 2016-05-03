From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: fix mdiobus_scan() error check
Date: Tue, 03 May 2016 15:04:25 -0400 (EDT)
Message-ID: <20160503.150425.768056572544917574.davem@davemloft.net>
References: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbcECTE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 15:04:28 -0400
In-Reply-To: <2317306.aZN9iKAKYz@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 01 May 2016 01:47:36 +0300

> Now mdiobus_scan() returns ERR_PTR(-ENODEV) instead of NULL if the PHY
> device ID was read as all ones. As this was not  an error before, this
> value  should be filtered out now in this driver.
> 
> Fixes: b74766a0a0fe ("phylib: don't return NULL from get_phy_device()")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
