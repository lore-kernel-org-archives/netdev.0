From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 02 May 2007 00:24:26 -0700 (PDT)
Message-ID: <20070502.002426.38687430.davem@davemloft.net>
References: <1178068656.4820.53.camel@dell>
	<46383B00.4080605@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754909AbXEBHYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 03:24:30 -0400
In-Reply-To: <46383B00.4080605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 02 May 2007 03:17:20 -0400

> Michael Chan wrote:
> > [BNX2]: Enhance the heartbeat.
> > 
> > In addition to the periodic heartbeat, we're adding a heartbeat
> > request interrupt when the heartbeat is late.  This is useful
> > especially in -rt kernels where the timer frequently runs late.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Should we really be adding code for such a special situation to upstream 
> code?
> 
> I lean towards "no", but defer to your and DaveM's judgement here.

My understanding of this situation is that if the timer is delayed a
lot, which can happen with the -rt kernel, we don't send the heartbeat
ping to the chip within the required margin.

If the margin is not met, the ASF firmware takes this as a signal that
the host system is down, and does things like reset the network card
and other things we don't want it to do.

Clarification from Michael would be appreciated, for sure.
