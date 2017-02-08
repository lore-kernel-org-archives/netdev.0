From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 8 Feb 2017 17:23:32 +0100
Message-ID: <20170208162332.GA13281@lunn.ch>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <87d96521-9d1f-f8e3-cea4-155b7522107e@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, rmk+kernel@armlinux.org.uk,
        Mao Wenan <maowenan@huawei.com>,
        Catalin Marinas <Catalin.Marinas@arm.com>
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60027 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751859AbdBHQY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 11:24:27 -0500
Content-Disposition: inline
In-Reply-To: <87d96521-9d1f-f8e3-cea4-155b7522107e@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:03:43PM +0000, Robin Murphy wrote:
> Hi all,
> 
> We're seeing a new boot-time crash[1] on SMSC911x hardware from this
> patch in today's HEAD (as cafe8df8b9bc)...

Hi Robin

Thank for the report. See the discussion on netdev under the subject
"Kernel crashes in phy_attach_direct()"

Andrew
