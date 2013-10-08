From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] moxa: fix the error handling in moxart_mac_probe()
Date: Tue, 08 Oct 2013 16:53:25 -0400 (EDT)
Message-ID: <20131008.165325.685988143607110163.davem@davemloft.net>
References: <CAPgLHd95agB+cseQmD4wg50wX_ddyZ0=0VxJ8vAR80ZbcFsMTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	jg1.han@samsung.com, b.zolnierkie@samsung.com,
	kyungmin.park@samsung.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790Ab3JHUx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:53:27 -0400
In-Reply-To: <CAPgLHd95agB+cseQmD4wg50wX_ddyZ0=0VxJ8vAR80ZbcFsMTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 8 Oct 2013 11:19:19 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> This patch fix the error handling in moxart_mac_probe():
>  - return -ENOMEM in some memory alloc fail cases
>  - add missing free_netdev() in the error handling case
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
