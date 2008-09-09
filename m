From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 05:25:09 -0700 (PDT)
Message-ID: <20080909.052509.152684932.davem@davemloft.net>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au>
	<48BE1B95.8000508@iki.fi>
	<20080903052329.GA8134@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36653
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754221AbYIIMZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:25:16 -0400
In-Reply-To: <20080903052329.GA8134@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 3 Sep 2008 15:23:30 +1000

> ipsec: Restore larval states and socket policies in dump
> 
> The commit commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3 ("[XFRM]:
> Speed up xfrm_policy and xfrm_state walking") inadvertently removed
> larval states and socket policies from netlink dumps.  This patch
> restores them.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6, thanks Herbert.
