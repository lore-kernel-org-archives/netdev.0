From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: b53: Fix statistics readings
Date: Tue, 21 Jun 2016 04:01:07 +0200
Message-ID: <20160621020107.GE20362@lunn.ch>
References: <1466472413-25824-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, jogo@openwrt.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53253 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbcFUCBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 22:01:47 -0400
Content-Disposition: inline
In-Reply-To: <1466472413-25824-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 06:26:53PM -0700, Florian Fainelli wrote:
> Due to a typo we would always be using the MIB counter width of the
> first element of the counter array instead of the current element, and
> we would always be accessing the register statistics with a 64-bits
> read, while some could be 32-bits. This got unnoticed in testing with
> MDIO and SRAB which tolerate doing this, but testing with the SPI bus
> revealed bogus values being returned. Fix this by using the proper
> iterator here.
> 
> Fixes: 967dd82ffc52 ("net: dsa: b53: Add support for Broadcom RoboSwitch")
> Reported-by: Jonas Gorski <jogo@openwrt.org>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
