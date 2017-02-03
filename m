From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/2] Work around missing PHY prodcut ID in
 mv88e6390
Date: Thu, 02 Feb 2017 21:51:15 -0500 (EST)
Message-ID: <20170202.215115.95019232393263464.davem@davemloft.net>
References: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdBCCvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:51:17 -0500
In-Reply-To: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  1 Feb 2017 03:40:04 +0100

> The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
> ID is zero. Work around this by trapping reads to the ID, and if it is
> zero, return the MV88E6390 family ID.
> 
> v2: Move the workaround into the central mdio read function.
>     Enable the temperature sensor, even though it does not work on the 6390,
>     but it does on the 6341, which has the same ID problem.

Series applied, thanks Andrew.
