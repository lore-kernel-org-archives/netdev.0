From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Trivial] net/wan/hdlc_ppp: remove dead goto
Date: Mon, 22 Aug 2011 13:52:00 -0700 (PDT)
Message-ID: <20110822.135200.2097710885170099050.davem@davemloft.net>
References: <alpine.LNX.2.00.1108130138100.7387@swampdragon.chaosbits.net>
	<20110818.220249.1523360015062657902.davem@davemloft.net>
	<alpine.LNX.2.00.1108212337380.8097@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: jj@chaosbits.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab1HVUw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 16:52:27 -0400
In-Reply-To: <alpine.LNX.2.00.1108212337380.8097@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 21 Aug 2011 23:38:51 +0200 (CEST)

> From: Jesper Juhl <jj@chaosbits.net>
> Subject: [PATCH] net/wan/hdlc_ppp: use break in switch
> 
> We'll either hit one of the case labels or the default in the switch
> and in all cases do we then 'goto out' and we also have a 'goto out'
> after the switch that is redundant. Change to just use break in the
> case statements and leave the 'goto out' after the lop for everyone to
> hit.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
