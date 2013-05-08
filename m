From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: fix return value check in efx_ptp_probe_channel()
Date: Wed, 08 May 2013 13:15:09 -0700 (PDT)
Message-ID: <20130508.131509.415569462200175410.davem@davemloft.net>
References: <CAPgLHd9-6uOYFs5PVSmxGmPBidtWNWk9ZK6O8s7_6KWQihu=4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab3EHUPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:15:10 -0400
In-Reply-To: <CAPgLHd9-6uOYFs5PVSmxGmPBidtWNWk9ZK6O8s7_6KWQihu=4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 7 May 2013 20:19:25 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function ptp_clock_register() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
