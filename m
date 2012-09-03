From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: fix possible memory leak in hfcmulti_init()
Date: Mon, 03 Sep 2012 15:37:53 -0400 (EDT)
Message-ID: <20120903.153753.1794768537163408659.davem@davemloft.net>
References: <CAPgLHd_vRu-ACoVhf2LwL_1pYXuvXArindYOpHh6T-syn_CVUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327Ab2ICTh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 15:37:59 -0400
In-Reply-To: <CAPgLHd_vRu-ACoVhf2LwL_1pYXuvXArindYOpHh6T-syn_CVUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 3 Sep 2012 15:31:00 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> hc has been allocated in this function and missing free it before
> leaving from some error handling cases.
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
