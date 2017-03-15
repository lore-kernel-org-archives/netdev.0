From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: check out-of-range ageing time
Date: Wed, 15 Mar 2017 22:05:56 +0100
Message-ID: <20170315210556.GA7416@lunn.ch>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50090 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751357AbdCOVGB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 17:06:01 -0400
Content-Disposition: inline
In-Reply-To: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patchset fixes this by adding ageing_time_min and ageing_time_max
> fields to the dsa_switch structure, which can optionally be set by a DSA
> driver.
> 
> If provided, the DSA core will check for out-of-range values in the
> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME prepare phase and return -ERANGE
> accordingly.
> 
> Finally set these limits in the mv88e6xxx driver.

Hi Vivien

Thanks for doing it this way. Nicely done.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
