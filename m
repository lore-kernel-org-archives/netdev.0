From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ethernet: moxa: remove unnecessary
 platform_set_drvdata()
Date: Thu, 22 Aug 2013 15:12:46 -0700 (PDT)
Message-ID: <20130822.151246.1012488577119770450.davem@davemloft.net>
References: <001901ce9eda$a9351310$fb9f3930$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jonas.jensen@gmail.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab3HVWMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 18:12:47 -0400
In-Reply-To: <001901ce9eda$a9351310$fb9f3930$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 22 Aug 2013 10:55:21 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
