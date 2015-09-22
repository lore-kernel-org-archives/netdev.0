From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA: phy polling
Date: Tue, 22 Sep 2015 04:14:26 +0200
Message-ID: <20150922021426.GE20288@lunn.ch>
References: <20150914104254.GI21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40929 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757632AbbIVCWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 22:22:34 -0400
Content-Disposition: inline
In-Reply-To: <20150914104254.GI21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 11:42:54AM +0100, Russell King - ARM Linux wrote:
> Andrew,
> 
> I think you're the current maintainer of the Marvell DSA code, as being
> the most recent author of changes to it. :)

Hi Russell

Sorry for the slow reply, i've been on vacation.

Humm, i suppose i might be the defacto Maintainer for Marvell parts,
but i've no NDA with Marvell, so no access to the data sheets etc.
 
> I've noticed in my testing that the Marvell DSA code seems to poll the
> internal phy link status in mv88e6xxx_poll_link(), and set the network
> device carrier status according to the results.

Peter Korsgaard comment might be correct, the switch needs to know
what the PHY has negotiated. Hence the use of the PPU. There are also
comments in the code that the PPU is needed for indirect access to the
PHY.

So we probably need to keep the PPU, but disable it from changing the
networks stacks idea of the link state, etc.

I will add this to my TODO list to play with it.

  Andrew
