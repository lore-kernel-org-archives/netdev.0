From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] stmmac: dwmac-socfpga: fix wrong pointer passed
 to PTR_ERR()
Date: Tue, 12 Jul 2016 11:08:08 -0700 (PDT)
Message-ID: <20160712.110808.50258557263593640.davem@davemloft.net>
References: <1468321209-15732-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, thloh@altera.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcGLSIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:08:10 -0400
In-Reply-To: <1468321209-15732-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 11:00:09 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> PTR_ERR should access the value just tested by IS_ERR, otherwise
> the wrong error code will be returned.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
