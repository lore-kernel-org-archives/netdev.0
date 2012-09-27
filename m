From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: fix return value check
Date: Thu, 27 Sep 2012 13:18:37 -0400 (EDT)
Message-ID: <20120927.131837.1439390105256553553.davem@davemloft.net>
References: <CAPgLHd9GYYu21FhiKAr2MvmYtWbL=85-E0EzJmiJm6cDDp=WcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab2I0RSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:18:38 -0400
In-Reply-To: <CAPgLHd9GYYu21FhiKAr2MvmYtWbL=85-E0EzJmiJm6cDDp=WcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 25 Sep 2012 12:29:35 +0800

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
