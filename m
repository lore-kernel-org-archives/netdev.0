From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Mon, 28 Nov 2016 15:14:10 +0100
Message-ID: <20161128141410.GF4379@lunn.ch>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59714 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933125AbcK1OOM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 09:14:12 -0500
Content-Disposition: inline
In-Reply-To: <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> 3 types of PHY loopback are supported.
> i.e. Near-End Loopback, Far-End Loopback and External Loopback.

Hi Allan

Is this integrated with ethtool --test? You only want the PHY to go
into loopback mode when running ethtool --test external_lb or maybe
ethtool --test offline.

What i think should happen is that this tunable sets the mode the PHY
will go into when loopback is enabled. It does not however enable
loopback. It is running ethtool --test which actually enables the
loopback, probably by setting BMCR_LOOPBACK. Once the test is
finished, the bit is cleared and the PHY goes back into normal
operation.

	Andrew
