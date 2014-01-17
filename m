From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net_sched: fix error return code in
 fw_change_attrs()
Date: Thu, 16 Jan 2014 19:12:21 -0800 (PST)
Message-ID: <20140116.191221.1772405375456874214.davem@davemloft.net>
References: <CAPgLHd_cjvdEcYZZNGg1rwKRBQcUS74vGvsdmTNkSWpPqR+fMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaAQDMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 22:12:22 -0500
In-Reply-To: <CAPgLHd_cjvdEcYZZNGg1rwKRBQcUS74vGvsdmTNkSWpPqR+fMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 17 Jan 2014 09:53:20 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The error code was not set if change indev fail, so the error
> condition wasn't reflected in the return value. Fix to return a
> negative error code from this error handling case instead of 0.
> 
> Fixes: 2519a602c273 ('net_sched: optimize tcf_match_indev()')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thank you.
