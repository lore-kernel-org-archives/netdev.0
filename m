From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/11] net: dsa: mv88e6xxx: refine port
 operations
Date: Fri, 04 Nov 2016 14:40:46 -0400 (EDT)
Message-ID: <20161104.144046.144416497334140758.davem@davemloft.net>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  4 Nov 2016 03:23:25 +0100

> The Marvell chips have one internal SMI device per port, containing a
> set of registers used to configure a port's link, STP state, default
> VLAN or addresses database, etc.
> 
> This patchset creates port files to implement the port operations as
> described in datasheets, and extend the chip ops structure with them.
> 
> Patches 1 to 6 implement accessors for port's STP state, port based VLAN
> map, default FID, default VID, and 802.1Q mode.
> 
> Patches 7 to 11 implement the port's MAC setup of link state, duplex
> mode, RGMII delay and speed, all accessed through port's register 0x01.
> 
> The new port's MAC setup code is used to re-implement the adjust_link
> code and correctly force the link down before changing any of the MAC
> settings, as requested by the datasheets.
> 
> The port's MAC accessors use values compatible with struct phy_device
> (e.g. DUPLEX_FULL) and extend them when needed (e.g. SPEED_MAX).
> 
> Changes in v2:
> 
>   - Strictly use new _UNFORCED values instead of re-using _UNKNOWN ones.

Series applied, thanks Vivien.
