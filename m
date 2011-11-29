From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 01:22:22 -0500 (EST)
Message-ID: <20111129.012222.1615213860721962427.davem@davemloft.net>
References: <1322511796-6908-2-git-send-email-igorm@etf.rs>
	<1322512426.2970.15.camel@edumazet-laptop>
	<1322515010.2970.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab1K2GWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:22:32 -0500
In-Reply-To: <1322515010.2970.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2011 22:16:50 +0100

> [PATCH net-next] net: dont call jump_label_dec from irq context
> 
> Igor Maravic reported an error caused by jump_label_dec() being called
> from IRQ context :
 ...
> Since jump_label_{inc|dec} must be called from process context only,
> we must defer jump_label_dec() if net_disable_timestamp() is called
> from interrupt context.
> 
> Reported-by: Igor Maravic <igorm@etf.rs>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
