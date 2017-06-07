From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed, 7 Jun 2017 14:12:05 +0200
Message-ID: <20170607121205.GC1271@lunn.ch>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39589 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751203AbdFGMMP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 08:12:15 -0400
Content-Disposition: inline
In-Reply-To: <20170607083810.30922-8-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 10:38:08AM +0200, Antoine Tenart wrote:
> This patch adds the xMDIO interface support in the mvmdio driver. This
> interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> of now). The xSMI interface supported by this driver complies with the
> IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> 22). The xSMI interface is used by 10GbE devices.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Hi Antoine

I've only take a quick look, but i don't see anywhere you look at the
register address and see if it has MII_ADDR_C45 to determine if a C45
transaction should be done, or a C22. The MDIO bus can have a mix of
C45 and C22 devices on it, and you need to use the correct transaction
type depending on the target device/address.

	  Andrew
