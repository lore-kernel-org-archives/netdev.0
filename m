From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v6 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 14:53:19 +0200
Message-ID: <20161004125319.GK11677@lunn.ch>
References: <1475581272-12093-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161004115132.GG11677@lunn.ch>
 <20161004122648.GA12301@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38561 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753657AbcJDMxV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:53:21 -0400
Content-Disposition: inline
In-Reply-To: <20161004122648.GA12301@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Regarding remove the -'s in table, PHY data sheet descript the
> concept of edge rate with table. I would like to keep the same table
> in driver.

The double negative makes the code ugly. Plus a negative slowdown is a
speed up! The kernel maintainability and sanity comes first, and if
the data sheet is crazy, because it uses negative slows downs, it
should be ignored. Get the data sheet fixed....

       Andrew
