From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: dsa: Move temperature sensor code into PHY.
Date: Fri, 20 Jan 2017 14:43:25 -0500 (EST)
Message-ID: <20170120.144325.630722726670636677.davem@davemloft.net>
References: <1484872670-32585-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdATTn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:43:27 -0500
In-Reply-To: <1484872670-32585-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 20 Jan 2017 01:37:48 +0100

> Marvell Ethernet switches contain a temperature sensor. There appears
> to be one sensor, which is shared by each of the internal PHYs. Each
> PHY has independent registers to read this sensor, and to set a limit
> for when an alarm should be raised.
> 
> Some Marvell discrete PHY also have the same sensor and registers.
> Moving the HWMON code from DSA into the PHY makes the sensor available
> in discrete PHYs, and removes the layering violation, the switch
> driver poking around in PHY registers.
> 
> While moving the code into the PHY driver, it has been re-written to
> use the new HWMON APIs.
> 
> v2:
> 
> Better Cover note explaining one sensor, but multiple independent
> registers
> 
> Simply error checking.

I know there was minor request for a respin, but I'm not going to hold
this up any more just for that.

Series applied, thanks Andrew.
