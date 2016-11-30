From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 2/2] net: phy: bcm7xxx: Plug in support for
 reading PHY error counters
Date: Wed, 30 Nov 2016 14:37:07 +0100
Message-ID: <20161130133707.GB18716@lunn.ch>
References: <20161129175718.20213-1-f.fainelli@gmail.com>
 <20161129175718.20213-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34968 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752557AbcK3NhL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:37:11 -0500
Content-Disposition: inline
In-Reply-To: <20161129175718.20213-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 09:57:18AM -0800, Florian Fainelli wrote:
> Broadcom BCM7xxx internal PHYs can leverage the Broadcom PHY library
> module PHY error counters helper functions, just implement the
> appropriate PHY driver function calls to do so. We need to allocate some
> storage space for our PHY statistics, and provide it to the Broadcom PHY
> library, so do this in a specific probe function, and slightly wrap the
> get_stats function call.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Hi Florian

Nice to see another PHY driver make use of this.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
