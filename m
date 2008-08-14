From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Create init functions for estimator code
Date: Thu, 14 Aug 2008 14:52:02 +1000
Message-ID: <20080814045200.GD13993@verge.net.au>
References: <alpine.LNX.1.10.0808140045230.12259@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	wensong@linux-vs.org, ja@ssi.bg
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56218 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYHNEwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 00:52:05 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808140045230.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 12:47:16AM +0200, Sven Wegener wrote:
> Commit 8ab19ea36c5c5340ff598e4d15fc084eb65671dc ("ipvs: Fix possible deadlock
> in estimator code") fixed a deadlock condition, but that condition can only
> happen during unload of IPVS, because during normal operation there is at least
> our global stats structure in the estimator list. The mod_timer() and
> del_timer_sync() calls are actually initialization and cleanup code in
> disguise. Let's make it explicit and move them to their own init and cleanup
> function.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

I like the simplification that this change brings.

Acked-by: Simon Horman <horms@verge.net.au>
