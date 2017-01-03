From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/3] net: dsa: restore HWMON support in dsa2
Date: Tue, 3 Jan 2017 19:33:52 +0100
Message-ID: <20170103183352.GA30638@lunn.ch>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41841 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965450AbdACSdz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 13:33:55 -0500
Content-Disposition: inline
In-Reply-To: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 01:15:35PM -0500, Vivien Didelot wrote:
> The current HWMON support in DSA in embedded in the legacy code.
> Extract it to its own file and register it in the newer DSA code.

Hi Vivien

I would really prefer not to do this.

The temperature sensor is in the embedded PHYs of the switch. Many of
Marvell discrete PHYs also have the same temperature sensor. The
correct thing to do is move this code into drivers/net/phy/marvell.c.

	Andrew
