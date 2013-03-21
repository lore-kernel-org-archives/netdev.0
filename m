From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lantiq_etop: use free_netdev(netdev) instead of kfree()
Date: Thu, 21 Mar 2013 11:50:48 -0400 (EDT)
Message-ID: <20130321.115048.379172511891255551.davem@davemloft.net>
References: <CAPgLHd8S_MBawcZQNKvKXBWes6bg=1y32GT_UYs215htg3AkZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, wfp5p@virginia.edu, jdmason@kudzu.us,
	gregkh@linuxfoundation.org, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933714Ab3CUPuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:50:50 -0400
In-Reply-To: <CAPgLHd8S_MBawcZQNKvKXBWes6bg=1y32GT_UYs215htg3AkZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 21 Mar 2013 15:31:42 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Freeing netdev without free_netdev() leads to net, tx leaks.
> And it may lead to dereferencing freed pointer.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
