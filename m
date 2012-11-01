From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Support the MX6 FEC as a PTP hardware clock
Date: Thu, 01 Nov 2012 12:30:27 -0400 (EDT)
Message-ID: <20121101.123027.1332984905040252720.davem@davemloft.net>
References: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznua@gmail.com, richardcochran@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508Ab2KAQag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:30:36 -0400
In-Reply-To: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Wed, 31 Oct 2012 12:24:40 +0800

> This patch series enables hardware time stamping and a PTP hardware clock
> for mx6 ENET controller.
> 
> Frank Li (4):
>   net: fec: move fec_enet_private to header file
>   ARM: dts: imx6q: Add ENET PTP clock pin and clock source
>   ARM: imx6q: Set enet tx reference clk from anatop to support 1588
>   FEC: Add time stamping code and a PTP hardware clock

All applied to net-next.

Please make sure your changes are in sync with Ben's PTP/PPS
Kconfig changes of today, and send me any changes if necessary.
