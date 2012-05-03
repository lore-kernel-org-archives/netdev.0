From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix truesize accounting in
 skb_gro_receive()
Date: Thu, 03 May 2012 13:22:49 -0400 (EDT)
Message-ID: <20120503.132249.1552815195596529055.davem@davemloft.net>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	<20120503071859.13636.30050.stgit@gitlad.jf.intel.com>
	<1336037601.3752.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab2ECRWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 13:22:52 -0400
In-Reply-To: <1336037601.3752.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 11:33:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> GRO is very optimistic in skb truesize estimates, only taking into
> account the used part of fragments.
> 
> Be conservative, and use more precise computation, so that bloated GRO
> skbs can be collapsed eventually.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
