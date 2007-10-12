From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 17:50:59 -0700
Message-ID: <20071011175059.7b35c9a1@freepuppy.rosehill>
References: <20071011165548.6545b207@freepuppy.rosehill>
	<20071011.171743.118962219.davem@davemloft.net>
	<20071011173149.5ec23a25@freepuppy.rosehill>
	<20071011.174026.26976971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43475 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751338AbXJLAvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:51:16 -0400
In-Reply-To: <20071011.174026.26976971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 17:40:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 11 Oct 2007 17:31:49 -0700
> 
> > You don't need to re-read the status register and process the PHY irq's inside loop.
> > Try this:
> 
> Are you sure?  What if a PHY interrupt comes in during the loop?

The interrupt is level triggered, and will rearm.

> 
> I'm just preserving the semantics of the driver when ->poll()
> is invoked multiple times per interrupt.
> 
> And I think preserving that makes sense while we're purely
> trying to fix this bug, so we don't add some new ones.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
