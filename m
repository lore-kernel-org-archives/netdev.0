From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v5 00/11] net: mvmdio: add xMDIO xSMI support
Date: Thu, 15 Jun 2017 17:30:20 +0200
Message-ID: <20170615153020.GC3786@lunn.ch>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50486 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751755AbdFOPa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 11:30:27 -0400
Content-Disposition: inline
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 15, 2017 at 04:43:15PM +0200, Antoine Tenart wrote:
> Hello,
> 
> This series aims to add the xSMI support on the xMDIO bus to the
> mvmdio driver. The xSMI interface complies with the IEEE 802.3 clause 45
> and is used by 10GbE devices. On 7k and 8k (as of now), such an
> interface is found and is used by Ethernet controllers.
> 
> Patches 1-4 and 9 are cosmetic cleanups.
> 
> Patches 5-7 are prerequisites to the xSMI support.
> 
> Patches 8 and 10-11 add the xSMI support to the mvmdio driver, and a
> node is added both in the cp110 slave and master device trees.
> 
> This was tested on an Armada 8040 mcbin, as well as on both the
> Armada 7040 DB and the Armada 8040 DB to ensure the SMI interface
> was still working.
> 
> @Dave: patch 11 should go through the mvebu tree as asked by Gregory,
> thanks!
> 
> Thanks,
> Antoine

Looks good.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
