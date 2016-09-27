From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: fec: updates to align IP header
Date: Tue, 27 Sep 2016 07:40:06 -0400 (EDT)
Message-ID: <20160927.074006.1952862778935087880.davem@davemloft.net>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
        <1474728139-9335-1-git-send-email-eric@nelint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk, andrew@lunn.ch,
        fugang.duan@nxp.com, otavio@ossystems.com.br, edumazet@google.com,
        troy.kisky@boundarydevices.com, u.kleine-koenig@pengutronix.de
To: eric@nelint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbcI0LkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 07:40:13 -0400
In-Reply-To: <1474728139-9335-1-git-send-email-eric@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Nelson <eric@nelint.com>
Date: Sat, 24 Sep 2016 07:42:16 -0700

> This patch series is the outcome of investigation into very high
> numbers of alignment faults on kernel 4.1.33 from the linux-fslc
> tree:
>     https://github.com/freescale/linux-fslc/tree/4.1-1.0.x-imx
> 
> The first two patches remove support for the receive accelerator (RACC) from
> the i.MX25 and i.MX27 SoCs which don't support the function.
> 
> The third patch enables hardware alignment of the ethernet packet payload
> (and especially the IP header) to prevent alignment faults in the IP stack.
> 
> Testing on i.MX6UL on the 4.1.33 kernel showed that this patch removed
> on the order of 70k alignment faults during a 100MiB transfer using 
> wget.
> 
> Testing on an i.MX6Q (SABRE Lite) board on net-next (4.8.0-rc7) showed
> a much more modest improvement from 10's of faults, and it's not clear
> why that's the case.

Series applied and queued up for -stable.
