From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 2 May 2007 10:44:35 -0700
Message-ID: <20070502104435.6471751e@localhost.localdomain>
References: <46383B00.4080605@garzik.org>
	<20070502.002426.38687430.davem@davemloft.net>
	<4638400D.5010306@garzik.org>
	<20070502.005412.99176640.davem@davemloft.net>
	<46384540.6090509@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39063 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766954AbXEBRtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 13:49:43 -0400
In-Reply-To: <46384540.6090509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 02 May 2007 04:01:04 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Wed, 02 May 2007 03:38:53 -0400
> > 
> >> * adding code for a situation that never occurs in the upstream kernel.
> > 
> > What we could do is simply have Ingo carry this bnx2 driver patch in
> > his -rt patch series, and then it will propagate into upstream as soon
> > as it matters.
> 
> Seems quite reasonable to me...
> 
> 	Jeff

Maybe if we used a hrtimer in this case, the -rt kernel wouldn't delay
the timer.  Seems like a real time system would have some mechanism
to ensure a timer fires in time.
