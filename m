From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v1 17/21] amd-xgbe: Add I2C support for
 determining SFP media types
Date: Thu, 3 Nov 2016 15:28:15 +0100
Message-ID: <20161103142815.GB1768@lunn.ch>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103133036.3437.71231.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35570 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753245AbcKCO2T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 10:28:19 -0400
Content-Disposition: inline
In-Reply-To: <20161103133036.3437.71231.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 08:30:36AM -0500, Tom Lendacky wrote:
> Add support to initialize and use the I2C controller within the hardware
> in order to determine the SFP media type that is installed.

Hi Tom

Did you see the work Russell King did for phylink?

https://lwn.net/Articles/667055/

Rather than doing your own proprietary i2c infrastructure, use the
standard Linux i2c infrastructure. The SFP modules are then just
normal i2c devices on a normal i2c bus. The work Russell did can then
access them, export them to user space, get the PHY modes correctly
setup, etc.

       Andrew
