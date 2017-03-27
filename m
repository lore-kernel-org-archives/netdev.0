From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next 3/3] net: phy: stop the PHY clock during LPI
 only if supported
Date: Mon, 27 Mar 2017 22:38:03 +0200
Message-ID: <20170327203803.GH17041@lunn.ch>
References: <20170327184721.30275-1-f.fainelli@gmail.com>
 <20170327184721.30275-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rmk+kernel@armlinux.org.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35902 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbdC0UiG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 16:38:06 -0400
Content-Disposition: inline
In-Reply-To: <20170327184721.30275-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 11:47:21AM -0700, Florian Fainelli wrote:
> Now that we detect whether a PHY supports stopping its clock during LPI,
> deny a call to phy_init_eee() with clk_stop_enable being set and the PHY
> not supporting that.

Hi Florian

We are not denying the call. This just ignores the clk_stop_enable
parameter if the clock cannot be stopped. So i think this message
could be better worded.

Maybe also update the function comment?

* and it programs the MMD register 3.0 setting the "Clock stop enable"
* bit if supported by the device.

  Andrew
