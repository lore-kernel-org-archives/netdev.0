From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] Interrupt support for mv88e6xxx
Date: Mon, 17 Oct 2016 11:18:44 -0400 (EDT)
Message-ID: <20161017.111844.816079254713993206.davem@davemloft.net>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932551AbcJQPSq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:18:46 -0400
In-Reply-To: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 16 Oct 2016 19:56:48 +0200

> This patchset add interrupt controller support to the MV88E6xxx.  This
> allows access to the interrupts the internal PHY generate. These
> interrupts can then be associated to a PHY device in the device tree
> and used by the PHY lib, rather than polling.
> 
> Since interrupt handling needs to make MDIO bus accesses, threaded
> interrupts are used. The phylib needs to request the PHY interrupt
> using the threaded IRQ API. This in term allows some simplification to
> the code, in that the phylib interrupt handler can directly call
> phy_change(), rather than use a work queue. The work queue is however
> retained for the phy_mac_interrupt() call, which can be called in hard
> interrupt context.
> 
> Since RFC v1:
> 
> Keep phy_mac_interrupt() callable in hard IRQ context.
> 
> The fix to trigger the phy state machine transitions on interrupts has
> already been submitted, so is dropped from here.
> 
> Added back shared interrupts support.

Series applied, thanks!
