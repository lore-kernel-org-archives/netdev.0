From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pktgen: fix null ptr deref in skb allocation
Date: Mon, 11 Jan 2016 17:40:31 -0500 (EST)
Message-ID: <20160111.174031.1199997012538036511.davem@davemloft.net>
References: <20160111053844.3695.82965.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bogdan.hamciuc@freescale.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759271AbcAKWkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:40:32 -0500
In-Reply-To: <20160111053844.3695.82965.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 10 Jan 2016 21:38:44 -0800

> Fix possible null pointer dereference that may occur when calling
> skb_reserve() on a null skb.
> 
> Fixes: 879c7220e82 ("net: pktgen: Observe needed_headroom of the device")
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I don't know how I missed that during review :-/

Applied and queued up for -stable, thanks!
