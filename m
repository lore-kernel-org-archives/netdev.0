From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix return value check in fib6_add()
Date: Fri, 21 Sep 2012 13:44:35 -0400 (EDT)
Message-ID: <20120921.134435.90667959444720339.davem@davemloft.net>
References: <CAPgLHd9vdKJfj1yUqU+zDaH6PiuqY8ZG_V5B1py--NiDwa+WkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab2IURoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:44:38 -0400
In-Reply-To: <CAPgLHd9vdKJfj1yUqU+zDaH6PiuqY8ZG_V5B1py--NiDwa+WkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 21 Sep 2012 12:29:56 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function fib6_add_1() returns ERR_PTR()
> or NULL pointer. The ERR_PTR() case check is missing in fib6_add().
> 
> dpatch engine is used to generated this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.

Longer term fib6_add_1() should consistently return errno pointers,
rather than a mixture of NULL and errno pointers.
