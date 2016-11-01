From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/11] net: dsa: mv88e6xxx: add port FID
 accessors
Date: Tue, 1 Nov 2016 10:38:19 +0100
Message-ID: <20161101093819.GA2802@lunn.ch>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com>
 <20161101032023.32762-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59658 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168260AbcKAJiX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 05:38:23 -0400
Content-Disposition: inline
In-Reply-To: <20161101032023.32762-5-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> --- a/drivers/net/dsa/mv88e6xxx/port.c
> +++ b/drivers/net/dsa/mv88e6xxx/port.c
> @@ -61,6 +61,8 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
>  	return 0;
>  }
>  
> +/* Offset 0x05: Port Control 1 */
> +
>  /* Offset 0x06: Port Based VLAN Map */
>  
>  int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)

Hi Vivien

This comment seems in an odd place.

     Andrew
