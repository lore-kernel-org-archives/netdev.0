From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix initialization of SGE_CONTROL register
Date: Wed, 07 Nov 2012 19:02:49 -0500 (EST)
Message-ID: <20121107.190249.916478194170672895.davem@davemloft.net>
References: <1352295946-32146-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab2KHACu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 19:02:50 -0500
In-Reply-To: <1352295946-32146-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Wed,  7 Nov 2012 19:15:46 +0530

> INGPADBOUNDARY_MASK is already shifted. No need to shift it again. On reloading
> a driver it was resulting in a bad SGE FL MTU sizes [1536, 9088] error. This
> only causes an issue on systems that have L1 cache size of 32B, 128B, 512B,
> 2048B or 4096B.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied, thanks.
