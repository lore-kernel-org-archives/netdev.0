From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 0/3] net/macb: fixes to use core on Zynq SoCs
Date: Thu, 28 Mar 2013 12:10:41 +0100
Message-ID: <51542531.9010300@atmel.com>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:38353 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab3C1LKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 07:10:50 -0400
In-Reply-To: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2013 10:07 AM, Steffen Trumtrar :
> Hi!
> 
> The Cadence GEM is also licensed for the Xilinx Zynq7000 SoCs.
> As Xilinx uses other reset defaults, some fixes are necessary to have it
> working there. And as the Zynq is dualcore, the clk_enables/disables now need
> to be atomic.
> 
> Changes in v2:
> 	- only 3/3 was changed to correctly use the atomic clk_[en|dis]able
> 
> Regards,
> Steffen

On the whole series:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, best regards.

> Steffen Trumtrar (3):
>   net/macb: clear tx/rx completion flags in ISR
>   net/macb: force endian_swp_pkt_en to off
>   net/macb: make clk_enable atomic
> 
>  drivers/net/ethernet/cadence/macb.c | 24 ++++++++++++++----------
>  drivers/net/ethernet/cadence/macb.h |  2 ++
>  2 files changed, 16 insertions(+), 10 deletions(-)
> 


-- 
Nicolas Ferre
