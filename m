From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: add extra RX drop counters for
 nodesc_trunc and noskb_drop
Date: Tue, 15 Jul 2014 22:53:56 -0700 (PDT)
Message-ID: <20140715.225356.2046608141773950507.davem@davemloft.net>
References: <alpine.LFD.2.03.1407141534440.19512@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbaGPFx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 01:53:57 -0400
In-Reply-To: <alpine.LFD.2.03.1407141534440.19512@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 15 Jul 2014 11:58:12 +0100

> Added a counter rx_noskb_drop for failure to allocate an skb.
> Summed the per-channel rx_nodesc_trunc counters earlier so that they can
>  be included in rx_dropped.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> Tested that new stats appear in ethtool -S.
> However, because of the way the GENERIC_STATs are defined, they appear
>  at the top of the output.  Does the order of stats matter?

I don't think the order matters.

Applied, thanks Edward.
