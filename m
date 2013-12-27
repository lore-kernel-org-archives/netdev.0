From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] core: remove old parameter for
 __dst_destroy_metrics_generic
Date: Fri, 27 Dec 2013 12:08:20 -0500 (EST)
Message-ID: <20131227.120820.827902523607182899.davem@davemloft.net>
References: <1388136405-25019-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069Ab3L0RIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 12:08:24 -0500
In-Reply-To: <1388136405-25019-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 27 Dec 2013 17:26:45 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when call __dst_destroy_metrics_generic, we always know who old is, so
> do not need to pass it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

It's a parameter so that we pass it in a register, rather than having the
caller and the function both have to perform a memory operation and load
the value.

It's an optimization.

I'm not applying this, sorry.
