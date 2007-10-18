From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] napi_synchronize: waiting for NAPI
Date: Thu, 18 Oct 2007 10:28:09 +1000
Message-ID: <1192667289.12879.0.camel@pasglop>
References: <20071017202640.171902388@linux-foundation.org>
	 <20071017202653.266566036@linux-foundation.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45878 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758512AbXJRA2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:28:37 -0400
In-Reply-To: <20071017202653.266566036@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-10-17 at 13:26 -0700, Stephen Hemminger wrote:
> plain text document attachment (napi-synchronize.patch)
> Some drivers with shared NAPI need a synchronization barrier.
> Also suggested by Benjamin Herrenschmidt for EMAC.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Just saw this patch, sorry, missed it. Same as you sent me on another
reply, I still think it needs the smp barrier. Can you have a look at
the one I posted today ?

Cheers,
Ben.


