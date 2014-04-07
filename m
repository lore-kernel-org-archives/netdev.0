From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 07 Apr 2014 14:56:05 -0400 (EDT)
Message-ID: <20140407.145605.1744792379075147420.davem@davemloft.net>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>
	<1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755930AbaDGS4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 14:56:08 -0400
In-Reply-To: <1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>
Date: Sat,  5 Apr 2014 12:35:06 +0800

> +#define DESC_DEF_CFG			0x14

You absolutely cannot do this.

You must document what the bits in the TX descriptor config field
mean, all of them.

I bet there is a bit in there somewhere which tells the chip to signal
an interrupt when the packet has been sent.

But since you haven't documented the descriptor fields properly with
a full set of macro defines, we can't know what bit that is.

I really am very disappointed in the quality of this driver, and you
can expect that there will be a lot of push back and requests for
changes before this driver will be even close to being ready for
inclusion.
