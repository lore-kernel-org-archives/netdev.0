From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: b53: Utilize common helpers for
 u64/MAC
Date: Wed, 4 Jan 2017 23:07:22 +0100
Message-ID: <20170104220722.GH4229@lunn.ch>
References: <20170104215320.19293-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, volodymyr.bendiuga@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44307 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031655AbdADWHa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 17:07:30 -0500
Content-Disposition: inline
In-Reply-To: <20170104215320.19293-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 01:53:20PM -0800, Florian Fainelli wrote:
> Utilize the two functions recently introduced: u64_to_ether() and
> ether_to_u64() instead of our own versions.

:-)

And i expect these have been tested on big endian systems. I never
thought to look if one of the other drivers already had them.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
