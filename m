From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 1 Feb 2017 10:22:09 +0000
Message-ID: <20170201102208.GM27312@n2100.armlinux.org.uk>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        Mao Wenan <maowenan@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43998 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdBAKWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 05:22:23 -0500
Content-Disposition: inline
In-Reply-To: <20170201024643.2050-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 06:46:43PM -0800, Florian Fainelli wrote:
> From: Mao Wenan <maowenan@huawei.com>
> 
> There is currently no reference count being held on the PHY driver,
> which makes it possible to remove the PHY driver module while the PHY
> state machine is running and polling the PHY. This could cause crashes
> similar to this one to show up:

Does this really solve the problem?  What if you use sysfs to unbind the
driver but without removing the module?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
