From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: mgmt unit interface changes
Date: Tue, 27 Jan 2009 17:29:44 -0800 (PST)
Message-ID: <20090127.172944.219399602.davem@davemloft.net>
References: <497A3046.7060202@nvidia.com>
	<20090127172705.d6ad4c56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, manfred@colorfullife.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40295
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbZA1B3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 20:29:46 -0500
In-Reply-To: <20090127172705.d6ad4c56.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 27 Jan 2009 17:27:05 -0800

> whee, a 50 second busy-wait.
> 
> Unnecessarily, afacit.  The sole caller calls this function from
> ->probe without any locks held?
> 
> I'd suggest that we
> 
> a) use schedule_timeout_uninterruptible(1) and
> 
> b) add a bit of user feedback (printk(".")?) so they don't get bored
> and hit the reset button (remember those?)

Agreed.
