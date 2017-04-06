From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2] net: dsa: mv88e6xxx: Make SMI c22/c45 read/write functions static
Date: Thu, 06 Apr 2017 15:47:31 -0400
Message-ID: <87efx548to.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170406194217.13927-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37382 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753323AbdDFTtB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:49:01 -0400
In-Reply-To: <20170406194217.13927-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> The SMI clause 22 & 45 read/write operations are local to the global2.c file,
> so make them static. This eliminates the following warning:
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
>
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
