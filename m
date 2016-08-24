From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Wed, 24 Aug 2016 14:50:50 +0200
Message-ID: <20160824125050.GB13406@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43260 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754505AbcHXMuv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:50:51 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 11:58:01AM +0000, Raju Lakkaraju wrote:
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> This is Microsemi's VSC 85xx PHY register definitions header file.

Hi Raju

No other phy driver has its registers separated from the code. So lets
see what Florian says about this.

However, if you are going to do this, please in the same patch remove
the same defines from the mscc.c file, and use this header file.

    Andrew
