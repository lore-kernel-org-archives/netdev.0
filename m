From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 18:00:19 +0100
Message-ID: <20170327170019.GR7909@n2100.armlinux.org.uk>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
 <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:41276 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdC0RBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 13:01:04 -0400
Content-Disposition: inline
In-Reply-To: <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 09:47:31AM -0700, Florian Fainelli wrote:
> On 03/27/2017 02:59 AM, Russell King wrote:
> > As EEE is able to work in SGMII mode as well, add it to the list of
> > permissable EEE modes that phy_init_eee() will accept.  This is
> > necessary so that EEE can work with an 88E1512 connected in SGMII mode.
> 
> As you mention in your cover letter, we should probably reverse this
> test and make it reject modes where EEE has no chance of being supported
> at all.

Want me to re-spin?  Any thought on which interface modes we should
explicitly exclude?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
