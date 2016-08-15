From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: macb: add missing free_netdev() on error in
 macb_probe()
Date: Sun, 14 Aug 2016 21:24:04 -0700 (PDT)
Message-ID: <20160814.212404.1846469136478011428.davem@davemloft.net>
References: <1471016634-32320-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcHOEYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 00:24:05 -0400
In-Reply-To: <1471016634-32320-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 12 Aug 2016 15:43:54 +0000

> Add the missing free_netdev() before return from function macb_probe()
> in the platform_get_irq() error handling case.
> 
> Fixes: c69618b3e4f2 ("net/macb: fix probe sequence to setup clocks earlier")
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
