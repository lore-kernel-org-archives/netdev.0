From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Thu, 26 Oct 2017 17:06:12 +0300
Message-ID: <20171026140612.b2wizj45ez672w6n@mwanda>
References: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
 <20171026131232.3bj236va56mawse4@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24983 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932234AbdJZOGm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:06:42 -0400
Content-Disposition: inline
In-Reply-To: <20171026131232.3bj236va56mawse4@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You have a "Marvell 88E1116R" device, right?

We used to set MII_88E1121_PHY_MSCR_RX_DELAY and MII_88E1121_PHY_MSCR_TX_DELAY
bits unconditionally but now it depends on phydev->interface.  I don't
know the code/hardware well enough to say what phydev->interface is for
you.

regards,
dan carpenter
