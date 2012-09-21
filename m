From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at91ether: return PTR_ERR if call to clk_get fails
Date: Thu, 20 Sep 2012 22:22:21 -0400 (EDT)
Message-ID: <20120920.222221.1362666243095294465.davem@davemloft.net>
References: <1348124676-6627-1-git-send-email-devendra.aaru@gmail.com>
	<505AC8D6.5080404@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devendra.aaru@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899Ab2IUCWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 22:22:22 -0400
In-Reply-To: <505AC8D6.5080404@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 20 Sep 2012 09:42:14 +0200

> On 09/20/2012 09:04 AM, Devendra Naga :
>> we are currently returning ENODEV, as the clk_get may give a exact
>> error code in its returned pointer, assign it to the ret by using the
>> PTR_ERR function, so that the subsequent goto label will jump to the
>> error path and clean the driver and return the error correctly.
>> 
>> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
> 
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied, thanks.
