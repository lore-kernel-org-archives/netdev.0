From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: fix build break with !CONFIG_OF
Date: Wed, 21 Dec 2011 01:04:46 -0500 (EST)
Message-ID: <20111221.010446.2013036438835639474.davem@davemloft.net>
References: <1324416029-28198-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	plagnioj@jcrosoft.com, jamie@jamieiles.com,
	linux-arm-kernel@lists.infradead.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1LUGHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 01:07:20 -0500
In-Reply-To: <1324416029-28198-1-git-send-email-olof@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olof Johansson <olof@lixom.net>
Date: Tue, 20 Dec 2011 13:20:29 -0800

> This fixes the build of the macb driver that was broken by the DT changes:
> 
> drivers/net/ethernet/cadence/macb.c:1503: error: implicit declaration of function 'of_match_ptr'
> drivers/net/ethernet/cadence/macb.c:1503: error: 'macb_dt_ids' undeclared here (not in a function)
> drivers/net/ethernet/cadence/macb.c:1503: error: initializer element is not constant
> drivers/net/ethernet/cadence/macb.c:1503: error: (near initialization for 'macb_driver.driver.of_match_table')
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> ---
> 
> Nicolas, care to ack this so I can apply it on top of the macb DT branch in arm-soc?

Yes, please apply it there.
