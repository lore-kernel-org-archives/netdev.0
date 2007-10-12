From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 17:40:26 -0700 (PDT)
Message-ID: <20071011.174026.26976971.davem@davemloft.net>
References: <20071011165548.6545b207@freepuppy.rosehill>
	<20071011.171743.118962219.davem@davemloft.net>
	<20071011173149.5ec23a25@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750987AbXJLAkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:40:23 -0400
In-Reply-To: <20071011173149.5ec23a25@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 11 Oct 2007 17:31:49 -0700

> You don't need to re-read the status register and process the PHY irq's inside loop.
> Try this:

Are you sure?  What if a PHY interrupt comes in during the loop?

I'm just preserving the semantics of the driver when ->poll()
is invoked multiple times per interrupt.

And I think preserving that makes sense while we're purely
trying to fix this bug, so we don't add some new ones.
