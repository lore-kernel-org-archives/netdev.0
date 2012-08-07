From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 07 Aug 2012 14:55:33 -0700 (PDT)
Message-ID: <20120807.145533.2161378343227639185.davem@davemloft.net>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	<1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab2HGVze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 17:55:34 -0400
In-Reply-To: <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 7 Aug 2012 21:15:27 +0100

> Some day the compiler may be smart enough to ignore the different
> between explicit and implicit zero-initialisation, and put it back in
> BSS.  Declaring this __cache_aligned_in_smp might be a better option.

I'm surprised it doesn't already do this.

It definitely puts scalar explicit zero initializers into the BSS.
