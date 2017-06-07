From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/2] net: emac: fix and unify emac_mdio functions
Date: Wed, 7 Jun 2017 16:14:26 +0200
Message-ID: <20170607141426.GC4874@lunn.ch>
References: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
 <dc3b77e7ead819001e09589d1f95eb6c1061f381.1496773338.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39729 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750920AbdFGOO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 10:14:28 -0400
Content-Disposition: inline
In-Reply-To: <dc3b77e7ead819001e09589d1f95eb6c1061f381.1496773338.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 03:51:16PM +0200, Christian Lamparter wrote:
> emac_mdio_read_link() was not copying the requested phy settings
> back into the emac driver's own phy api. This has caused a link
> speed mismatch issue for the AR8035 as the emac driver kept
> trying to connect with 10/100MBps on a 1GBit/s link.
> 
> This patch also unifies shared code between emac_setup_aneg()
> and emac_mdio_setup_forced(). And furthermore it removes
> a chunk of emac_mdio_init_phy(), that was copying the same
> data into itself.
> 
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
