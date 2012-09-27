From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix return value check
Date: Thu, 27 Sep 2012 13:18:29 -0400 (EDT)
Message-ID: <20120927.131829.1820864299480573466.davem@davemloft.net>
References: <CAPgLHd_qnPZq34uP2dnZKtcXKtB4Da29wO12jHr5N44dKr=KKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376Ab2I0RSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:18:33 -0400
In-Reply-To: <CAPgLHd_qnPZq34uP2dnZKtcXKtB4Da29wO12jHr5N44dKr=KKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 25 Sep 2012 12:29:01 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function genlmsg_put() returns NULL pointer
> not ERR_PTR(). The IS_ERR() test in the return value check should
> be replaced with NULL test.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
