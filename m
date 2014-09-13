From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: stmmac: fix return value check in
 socfpga_dwmac_parse_data()
Date: Sat, 13 Sep 2014 16:43:08 -0400 (EDT)
Message-ID: <20140913.164308.397287761632853991.davem@davemloft.net>
References: <1410477177-5681-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaIMUnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:43:10 -0400
In-Reply-To: <1410477177-5681-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Fri, 12 Sep 2014 07:12:57 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function devm_ioremap_resource() returns
> ERR_PTR() and never returns NULL. The NULL test in the return
> value check should be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
