From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1 net-next] net: fec: add napi support to improve
 proformance
Date: Tue, 29 Jan 2013 14:18:00 -0500 (EST)
Message-ID: <20130129.141800.2181207237672109119.davem@davemloft.net>
References: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806Ab3A2TSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:18:02 -0500
In-Reply-To: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Tue, 29 Jan 2013 12:31:42 +0800

> Add napi support
 ...
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.

Note that it is recommended to also to TX reclaim processing
in the NAPI handler as well, in fact it's best to make the hardware
interrupt handler do nothing other than trigger NAPI and then
move everything that was in your hardware interrupt handler into
NAPI poll instead.
