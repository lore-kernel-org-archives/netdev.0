From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix return value check in
 stmmac_open_ext_timer()
Date: Fri, 21 Sep 2012 13:47:36 -0400 (EDT)
Message-ID: <20120921.134736.1491471500558263203.davem@davemloft.net>
References: <CAPgLHd87SqVa40-SGrgEfRAPWj1dr9aGPDD7b3aALCqka2ssuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345Ab2IURrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:47:41 -0400
In-Reply-To: <CAPgLHd87SqVa40-SGrgEfRAPWj1dr9aGPDD7b3aALCqka2ssuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 21 Sep 2012 15:06:10 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function clk_get() returns ERR_PTR()
> and never returns NULL pointer. The NULL test in the error
> handling should be replaced with IS_ERR().
> 
> dpatch engine is used to auto generated this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
