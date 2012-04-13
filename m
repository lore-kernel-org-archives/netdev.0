From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Fri, 13 Apr 2012 14:05:30 -0400 (EDT)
Message-ID: <20120413.140530.1601238090432836188.davem@davemloft.net>
References: <1334339980-2955-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, sboyd@codeaurora.org, ben@simtec.co.uk,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab2DMSHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 14:07:02 -0400
In-Reply-To: <1334339980-2955-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mjr@cs.wisc.edu
Date: Fri, 13 Apr 2012 12:59:40 -0500

> From: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> Move the ks8851_rdreg16 call above the call to request_irq and cache
> the result for subsequent repeated use.  A spurious interrupt may
> otherwise cause a crash.  Thanks to Stephen Boyd, Flavio Leitner, and
> Ben Hutchings for feedback.
> 
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>

Applied, thanks.
