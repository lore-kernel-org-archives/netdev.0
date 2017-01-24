From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] External MDIO support for mv88e6xxx
Date: Tue, 24 Jan 2017 15:35:04 -0500 (EST)
Message-ID: <20170124.153504.1132892597644436492.davem@davemloft.net>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdAXUfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:35:06 -0500
In-Reply-To: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 24 Jan 2017 14:53:46 +0100

> The mv88e6390 family of switches has two MDIO busses, one internal to
> the switch and a second one for external usage. Older generations of switches
> have a single MDIO bus, which is used both internally and externally.
> 
> Refactor the existing MDIO driver code to allow for multiple MDIO
> busses, and implement the second MDIO bus on mv88e6390.
> 
> This is a rewrite of a patch previously submitted as part of "Batch
> 3". It has been broken up into 5 smaller patches. A compatible string
> is now used in the device tree to indicate the external MDIO bus.

Series applied, thanks Andrew.

There seems to be a bit of inconsistency wrt. tab vs. space for
indentation in the binding files, just FYI.  I had to make some small
adjustments to this patch series in order to keep GIT from warning
when I applied this stuff.
