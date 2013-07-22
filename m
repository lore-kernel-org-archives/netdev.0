From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] fec: Improve resources handling
Date: Mon, 22 Jul 2013 16:51:40 -0700 (PDT)
Message-ID: <20130722.165140.863613697980137078.davem@davemloft.net>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
	<CAHrpEqTq=B97DJTEbdFQt_aqUAe-FHzoZbfeHQtjdzDoZbKzTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org
To: lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab3GVXvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 19:51:44 -0400
In-Reply-To: <CAHrpEqTq=B97DJTEbdFQt_aqUAe-FHzoZbfeHQtjdzDoZbKzTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <lznuaa@gmail.com>
Date: Mon, 22 Jul 2013 12:21:58 +0800

> 2013/7/22 Fabio Estevam <festevam@gmail.com>:
>> This series improves clock handling in the driver by not enabling/disabling
>> the optional ptp and enet_out clocks unconditionally, check for the return value
>> of clk_prepare_enable and also handle clk_ptp in suspend/resume.
>>
>> Remove an unneeded check in platform_get_resource() and also use
>> devm_request_irq() that can help to simplify the code.
>>
>> Fabio Estevam (6):
>>   fec: Do not enable/disable optional clocks unconditionally
>>   fec: Fix the order for enabling/disabling the clocks
>>   fec: Enable/disable clk_ptp in suspend/resume
>>   fec: Check the return value from clk_prepare_enable()
>>   fec: Remove unneeded check in platform_get_resource()
>>   fec: Use devm_request_irq()
>>
>>  drivers/net/ethernet/freescale/fec_main.c | 110 ++++++++++++++++++++----------
>>  1 file changed, 73 insertions(+), 37 deletions(-)
> 
> Acked

Series applied to net-next, thanks.
