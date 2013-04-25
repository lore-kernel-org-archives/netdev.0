From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: spi: missing platform_driver_unregister() on
 error in cfspi_init_module()
Date: Thu, 25 Apr 2013 03:52:18 -0400 (EDT)
Message-ID: <20130425.035218.1019119315985432675.davem@davemloft.net>
References: <CAPgLHd8BY8bbBS39Y5HP=qMo7p3OGGcQ9LD8ptiXvwees2QjzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3DYHwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:52:20 -0400
In-Reply-To: <CAPgLHd8BY8bbBS39Y5HP=qMo7p3OGGcQ9LD8ptiXvwees2QjzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 25 Apr 2013 15:15:23 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing platform_driver_unregister() before return
> from cfspi_init_module() in the error handling case.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.

The label was even already there to accomodate this.:-)
