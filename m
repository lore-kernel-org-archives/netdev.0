From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Tue, 02 Jan 2007 21:26:05 -0800 (PST)
Message-ID: <20070102.212605.15263907.davem@davemloft.net>
References: <1167800285.6165.105.camel@localhost.localdomain>
	<20070102.211158.35016452.davem@davemloft.net>
	<1167801614.6165.117.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbXACF0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 00:26:08 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1167801614.6165.117.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 03 Jan 2007 16:20:14 +1100

> Now, I cross-over with a TG3 and I get:
> 
>  - I advertise 0x5e1 (hopefully same value)
>  - I read in LPA 0xc5e1 from the TG3
> (and that other register tells me Rx and Tx pause can be enabled).

Does flow control get enabled with the TG3 on these
switches?  Just curious.

> > You should try to use flow control, even slower than 1000Mbit links.
> 
> Sorry, not sure I parse ;-) You mean allowing pause on 10 and 100 as
> well ? I sure can, it's easy to fix.

That's correct.

> > That's the only problem I can see, would you mind fixing that and
> > I'll put your change into my net-2.6 tree and perhaps play around
> > with PAUSE on my switches here?
> 
> Sure will do.

Thanks a lot.
