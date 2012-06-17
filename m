From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: lpc_eth: free skbs in start_xmit
Date: Sun, 17 Jun 2012 16:28:52 -0700 (PDT)
Message-ID: <20120617.162852.2208481357025267726.davem@davemloft.net>
References: <1339568172.22704.312.camel@edumazet-glaptop>
	<4FD85D27.5090509@antcom.de>
	<1339581496.22704.346.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stigge@antcom.de, netdev@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab2FQX2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:28:53 -0400
In-Reply-To: <1339581496.22704.346.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jun 2012 11:58:16 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Transmitted skbs can be freed immediately in lpc_eth_hard_start_xmit()
> instead of at TX completion, since driver copies the frames in DMA area.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Roland Stigge <stigge@antcom.de>

Applied.
