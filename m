From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] dwc_eth_qos: fix missing clk_disable_unprepare()
 on error in dwceqos_probe()
Date: Tue, 12 Jul 2016 11:08:24 -0700 (PDT)
Message-ID: <20160712.110824.1955203836548509477.davem@davemloft.net>
References: <1468323817-6159-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbcGLSIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:08:25 -0400
In-Reply-To: <1468323817-6159-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 11:43:37 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix missing clk_disable_unprepare() call before return
> from dwceqos_probe() in the error handling case of invalid
> fixed-link.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
