From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 2/2] net: emac: fix and unify emac_mdio functions
Date: Mon, 5 Jun 2017 23:43:33 +0200
Message-ID: <20170605214333.GA12386@lunn.ch>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
 <18472d9a6bde3edaab7dcda301ccaebd437ea0dc.1496695540.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37115 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751242AbdFEVnf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 17:43:35 -0400
Content-Disposition: inline
In-Reply-To: <18472d9a6bde3edaab7dcda301ccaebd437ea0dc.1496695540.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 10:49:40PM +0200, Christian Lamparter wrote:
> emac_mdio_read_link() was not copying the requested phy settings
> back into the emac driver's own phy api. This has caused a link
> speed mismatch issue for the AR8035 as the emac driver kept
> trying to connect with 10/100MBps on a 1GBit/s link.

Hi Christian

In the long run, you might want to remove the emac phy drivers. Linux
has PHYLIB drivers for all but the bcm5248.

       Andrew
