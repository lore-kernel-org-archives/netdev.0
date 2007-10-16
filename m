From: David Miller <davem@davemloft.net>
Subject: Re: netif_napi_add vs. multiple netdev's
Date: Tue, 16 Oct 2007 16:50:20 -0700 (PDT)
Message-ID: <20071016.165020.55724864.davem@davemloft.net>
References: <20071016091035.5fcd6d2e@freepuppy.rosehill>
	<20071016.151616.70218795.davem@davemloft.net>
	<20071016163724.28fc1df0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756036AbXJPXuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 19:50:15 -0400
In-Reply-To: <20071016163724.28fc1df0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 16 Oct 2007 16:37:24 -0700

> It isn't possible, there is only one hardware IRQ, and one
> common status buffer.

Ok, thanks for explaining.  Your hardware is very similar to
Ben's, therefore.

> I'll fix the suspend code, it has other problems as well.

Great!
