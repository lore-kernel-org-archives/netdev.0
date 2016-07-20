From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: cpmac: fix error handling of cpmac_probe()
Date: Wed, 20 Jul 2016 14:48:19 -0700 (PDT)
Message-ID: <20160720.144819.2077098867499042858.davem@davemloft.net>
References: <1468931873-19614-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, varkab@cdac.in, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbcGTVsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 17:48:20 -0400
In-Reply-To: <1468931873-19614-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj_lk@163.com>
Date: Tue, 19 Jul 2016 12:37:53 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing free_netdev() before return from function
> cpmac_probe() in the error handling case.
> This patch revert commit 0465be8f4f1d ("net: cpmac: fix in
> releasing resources"), which changed to only free_netdev
> while register_netdev failed.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
