From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Mon, 06 Jan 2014 16:18:46 -0500 (EST)
Message-ID: <20140106.161846.332183513263839789.davem@davemloft.net>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
	<20140106.154330.1324356005311602000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbaAFVSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:18:48 -0500
In-Reply-To: <20140106.154330.1324356005311602000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 06 Jan 2014 15:43:30 -0500 (EST)

> That the gre offload bits won't be registered unless GRE is enabled and
> initialized/loaded, right?

In fact, it's utterly and completely bogus to make only this change.
It breaks the build, I'm reverting:

ERROR: "gre_offload_exit" [net/ipv4/gre.ko] undefined!
ERROR: "gre_offload_init" [net/ipv4/gre.ko] undefined!
