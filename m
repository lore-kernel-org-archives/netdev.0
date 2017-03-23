From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: phy: Export mdiobus_register_board_info()
Date: Thu, 23 Mar 2017 08:41:36 +0100
Message-ID: <20170323074136.GD10076@lunn.ch>
References: <20170323054030.14613-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58051 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751455AbdCWHlj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 03:41:39 -0400
Content-Disposition: inline
In-Reply-To: <20170323054030.14613-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 10:40:30PM -0700, Florian Fainelli wrote:
> We can build modular code that uses mdiobus_register_board_info() which would
> lead to linking failure since this symbol is not expoerted.
> 
> Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
