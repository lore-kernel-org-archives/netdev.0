From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 15:57:55 -0400 (EDT)
Message-ID: <20140522.155755.1647601791759631898.davem@davemloft.net>
References: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaEVT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:57:57 -0400
In-Reply-To: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 22 May 2014 16:36:55 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> the value of itag is a random value from stack, and may not be initiated by
> fib_validate_source, which called fib_combine_itag if CONFIG_IP_ROUTE_CLASSID
> is not set
> 
> This will make the cached dst uncertainty
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied and queued up for -stable, thanks.
