From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: increase unres_qlen by one magnitude
Date: Tue, 08 Nov 2011 17:48:20 -0500 (EST)
Message-ID: <20111108.174820.558780148839093199.davem@davemloft.net>
References: <1320783085.2588.17.camel@edumazet-laptop>
	<20111108.172448.2101648110512252549.davem@davemloft.net>
	<1320792301.26025.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab1KHWsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:48:23 -0500
In-Reply-To: <1320792301.26025.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2011 23:45:01 +0100

> Maybe we can do the same for unres_qlen, and setup a byte limit instead
> of 3 packets limit (say 64Kbytes of truesize per destination)

That makes sense because what typically gets blocked are initial TCP SYNs,
small UDP requests, and ICMPs.
