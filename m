From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] jme: GHC register control fix for new
 hardware
Date: Wed, 03 Dec 2008 21:20:19 -0800 (PST)
Message-ID: <20081203.212019.109559554.davem@davemloft.net>
References: <20081008215853.M53590@cooldavid.org>
	<20081203103825.M4442@cooldavid.org>
	<49369F09.2010302@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	ethanhsiao@jmicron.com, akeem@jmicron.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751966AbYLDFUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 00:20:19 -0500
In-Reply-To: <49369F09.2010302@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Wed, 03 Dec 2008 10:00:25 -0500

> Guo-Fu Tseng wrote:
> > Dear Jeff, David:
> > Due to the hardware design, except the first chip on the market,
> > other chips needs to setup the clock source for MAC processor
> > implicitly through Global Host Control Register(GHC).
> > (Strange design huh?)
> > 10/100M uses the PCI-E as clock source, and 1G uses GPHY.
> > And I reordered the code a little, to make it easier to read.
> > Found-by: "Ethan" <ethanhsiao@jmicron.com>
> > Fixed-by: "akeemting" <akeem@jmicron.com>
> > Signed-off-by: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
> 
> patches 1-2 Acked-by: Jeff Garzik <jgarzik@redhat.com>

Both patches applied to net-next-2.6, thanks everyone.
