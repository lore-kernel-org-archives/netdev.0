From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3]: via-velocity: Fixes for locking issues
Date: Wed, 10 Feb 2010 10:55:49 -0800 (PST)
Message-ID: <20100210.105549.02581254.davem@davemloft.net>
References: <20100205165253.3f316b98@marrow.netinsight.se>
	<20100209.163133.38216503.davem@davemloft.net>
	<20100210103358.41a45851@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, ben@decadent.org.uk
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756408Ab0BJSzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 13:55:37 -0500
In-Reply-To: <20100210103358.41a45851@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Wed, 10 Feb 2010 10:33:58 +0100

> Anyway, when you are happy with the patch series, I think it is 2.6.33
> material as the velocity driver would otherwise contain a regression
> compared to 2.6.32.
> 
> Changes in the patch series:
> 
> * Patch 1: Unchanged
> 
> * Patch 2: Unchanged
> 
> * Patch 3: Use spin_lock_irqsave in velocity_poll and remove
>   spin_trylock from the interrupt handler.

Looks good, all applied to net-2.6, thanks!
