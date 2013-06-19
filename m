From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bcm63xx_enet: fix return value check in
 bcm_enet_shared_probe()
Date: Wed, 19 Jun 2013 00:49:19 -0700 (PDT)
Message-ID: <20130619.004919.1567267368837634118.davem@davemloft.net>
References: <CAPgLHd_=CCFcpkJP_717-hLREO+DBhYKNVpupmJik0oRnLGA3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jogo@openwrt.org, mbizon@freebox.fr, joe@perches.com,
	cernekee@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab3FSHtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 03:49:20 -0400
In-Reply-To: <CAPgLHd_=CCFcpkJP_717-hLREO+DBhYKNVpupmJik0oRnLGA3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 19 Jun 2013 10:32:32 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function devm_ioremap_resource() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
> 
> Introduce by commit 0ae99b5fede6f3a8d252d50bb4aba29544295219
> (bcm63xx_enet: split DMA channel register accesses)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
