From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: axienet: Fix return value check in
 axienet_probe()
Date: Wed, 20 Jul 2016 14:47:51 -0700 (PDT)
Message-ID: <20160720.144751.2198896469609054053.davem@davemloft.net>
References: <1468927404-32270-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, srikanth.thokala@xilinx.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbcGTVrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 17:47:53 -0400
In-Reply-To: <1468927404-32270-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj_lk@163.com>
Date: Tue, 19 Jul 2016 11:23:24 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function of_parse_phandle() returns NULL
> pointer not ERR_PTR(). The IS_ERR() test in the return value
> check should be replaced with NULL test.
> 
> Fixes: 46aa27df8853 ('net: axienet: Use devm_* calls')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
