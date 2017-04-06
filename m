From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: Provide prototypes for
 SMI read/write functions
Date: Thu, 6 Apr 2017 16:07:24 +0200
Message-ID: <20170406140724.GB17713@lunn.ch>
References: <20170406134736.24329-1-f.fainelli@gmail.com>
 <20170406134736.24329-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47763 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934788AbdDFOH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 10:07:26 -0400
Content-Disposition: inline
In-Reply-To: <20170406134736.24329-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 06:47:36AM -0700, Florian Fainelli wrote:
> Fixes the following warnings:
> 
> drivers/net/dsa/mv88e6xxx/global2.c:571:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c45' [-Wmissing-prototypes]
>  int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/dsa/mv88e6xxx/global2.c:602:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c22' [-Wmissing-prototypes]
>  int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/dsa/mv88e6xxx/global2.c:635:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c45' [-Wmissing-prototypes]
>  int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/dsa/mv88e6xxx/global2.c:664:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c22' [-Wmissing-prototypes]
>  int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hi Florian

These are not used outside of global2.c. So just mark them static.

      Andrew
