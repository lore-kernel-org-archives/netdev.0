From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/5] ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 13:13:32 +0100
Message-ID: <20161104121332.GJ13959@lunn.ch>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36809 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761368AbcKDMNf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:13:35 -0400
Content-Disposition: inline
In-Reply-To: <1478255742-25693-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 11:35:39AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Adding get_tunable/set_tunable function pointer to the phy_driver
> structure, and uses these function pointers to implement the
> ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE ioctls.

Hi Allan

For consistency, it would also be nice to add code in
__ethtool_get_strings().

	Andrew
