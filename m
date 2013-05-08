From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: fix error return code in bfin_sir_open()
Date: Wed, 08 May 2013 13:14:58 -0700 (PDT)
Message-ID: <20130508.131458.685560785825127949.davem@davemloft.net>
References: <CAPgLHd_MWMBjPhhd=md5AH2kG0=tnPc_9Ka44cA7zD4a3R5k2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169Ab3EHUO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:14:59 -0400
In-Reply-To: <CAPgLHd_MWMBjPhhd=md5AH2kG0=tnPc_9Ka44cA7zD4a3R5k2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 7 May 2013 20:14:33 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENOMEM in the irlap_open() error handling case instead
> of 0(overwrite to 0 by bfin_sir_startup()), as done elsewhere in this
> function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
