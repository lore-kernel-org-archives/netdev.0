From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 16:33:15 +0200
Message-ID: <20160831143315.GD15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com>
 <20160831132534.GA15078@lunn.ch>
 <87vayhvx0m.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vayhvx0m.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Does the bridge code use multicast group when referring to L2?
> 
> The switchdev MDB attribute is very similary to the FDB attribute. It
> contains the VLAN ID and the Ethernet MAC address of the group.

Hi Vivien

I'm just trying to avoid the use of 'multicast group' for a L2 entity,
unless it is already widespread used so in the bridge code. If the
bridge code does consider L2 a 'multciast group', fine, lets document
it so. But if the bridge code only uses 'multciast group' to mean L3,
we should not use it here for L2.

       Andrew
