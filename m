From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 18:31:05 -0500 (EST)
Message-ID: <20131219.183105.2179319099972646699.davem@davemloft.net>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	richardcochran@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3LSXbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:31:09 -0500
In-Reply-To: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Dec 2013 10:53:02 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_tx_timestamp(skb) should be called _before_ TX completion
> has a chance to trigger, otherwise it is too late and we access
> freed memory.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix dead lock")

Applied and queued up for -stable, thanks.
