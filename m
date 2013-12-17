From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net/hsr: using kfree_rcu() to simplify the code
Date: Tue, 17 Dec 2013 16:32:44 -0500 (EST)
Message-ID: <20131217.163244.446024637480081415.davem@davemloft.net>
References: <CAPgLHd_doYrTYAHyR4OrDz9B84Abh1H0MBvmi8XfCqAEVFyS_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Arvid.Brodin@xdin.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab3LQVcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:32:46 -0500
In-Reply-To: <CAPgLHd_doYrTYAHyR4OrDz9B84Abh1H0MBvmi8XfCqAEVFyS_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 16 Dec 2013 14:05:50 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The callback function of call_rcu() just calls a kfree(), so we
> can use kfree_rcu() instead of call_rcu() + callback function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
