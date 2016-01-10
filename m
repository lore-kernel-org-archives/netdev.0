From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Sun, 10 Jan 2016 08:22:17 -0800
Message-ID: <56928539.1060009@roeck-us.net>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch> <56914D21.9050804@roeck-us.net>
 <20160109205240.GA6877@lunn.ch> <569275C0.1040606@roeck-us.net>
 <20160110154945.GD22229@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160110154945.GD22229@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2016 07:49 AM, Andrew Lunn wrote:
>> How about those ?
>>
>> drivers/net/ethernet/freescale/ucc_geth.c: In function 'uec_configure_serdes':
>> drivers/net/ethernet/freescale/ucc_geth.c:1719:20: error: 'struct phy_device' has no member named 'dev'
>>
>> drivers/net/ethernet/freescale/fs_enet/mac-fec.c: In function 'stop':
>> drivers/net/ethernet/freescale/fs_enet/mac-fec.c:366:36: error: 'struct phy_device' has no member named 'bus'
>
> Not seen fixes for those, nor error reports either.
>
Ok, I'll see if I can fix those.

Also:

drivers/net/ethernet/amd/au1000_eth.c:  /* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
	[ no idea what to do with that comment ]
drivers/net/ethernet/broadcom/sb1250-mac.c:             phy_dev = sc->mii_bus->phy_map[i];
	[ can use phy_find_first ]
drivers/staging/netlogic/xlr_net.c:     struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
	[ several ]	

> I think the next time i do something like this, i'm going to ask you
> to run some built tests for me! You seem to have better coverage than
> 0-day.
>
Sure, no problem.

Guenter
