From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY
 layer functionality
Date: Sun, 2 Dec 2007 01:22:35 +0300
Message-ID: <20071202012235.4ad9abc3@kernel.crashing.org>
References: <20071126142906.19642.45540.stgit@localhost.localdomain>
	<47516646.9000803@scram.de>
	<20071201213403.GA2350@zarina>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jochen Friedrich <jochen@scram.de>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: cbou@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41584 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbXLAWW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 17:22:59 -0500
In-Reply-To: <20071201213403.GA2350@zarina>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Dec 2007 00:34:03 +0300
Anton Vorontsov wrote:

> > If i understand your code correctly, you seem to rely on the fact 
> > that fixed_phy_add() is called before the fixed MDIO bus is scanned
> > for devices.  
> 
> Yes, indeed. The other name of "fixed phys" are "platform phys"
> or "platform MDIO bus" on which virtual PHYs are placed.
> 
> That is, these phys supposed to be created by the platform setup
> code (arch/). The rationale here is: we do hardware emulation, thus
> to make drivers actually see that "hardware", we have to create it
> early.

well that was the intention but... The point is - as device is emulated, (nearly) everything is doable,
and the only tradeoff to consider, is how far will we go with that emulation. IOW, PHYlib could be tricked
to "do the right thing", and I thought about adding module flexibility...

But thinking more about it, it seems that BSP-code-phy-creation just sucks less and is clear enough yet flexible.
-- 
Sincerely, Vitaly
