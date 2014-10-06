From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/1] net: fec: fix build error at m68k
 platform
Date: Mon, 06 Oct 2014 00:22:10 -0400 (EDT)
Message-ID: <20141006.002210.1583510707427565787.davem@davemloft.net>
References: <1412371754-60384-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, netdev@vger.kernel.org, b38611@freescale.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaJFEWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:22:14 -0400
In-Reply-To: <1412371754-60384-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Fri, 3 Oct 2014 14:29:14 -0700

> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 1b7bde6d659d30f171259cc2dfba8e5dab34e735
> 
>   make.cross ARCH=m68k m5275evb_defconfig
>   make.cross ARCH=m68k
> 
> All error/warnings:
> 
>    drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_rx_queue':
>>> drivers/net/ethernet/freescale/fec_main.c:1470:3: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
>       prefetch(skb->data - NET_IP_ALIGN);
>       ^
>    cc1: some warnings being treated as errors
> 
> missed included prefetch.h
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied, thanks.
