From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 10:57:27 -0400
Message-ID: <871t157zqg.fsf@ketchup.mtl.sfl>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com> <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com> <20160831132534.GA15078@lunn.ch> <87vayhvx0m.fsf@ketchup.mtl.sfl> <20160831143315.GD15078@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831143315.GD15078@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> > Does the bridge code use multicast group when referring to L2?
>> 
>> The switchdev MDB attribute is very similary to the FDB attribute. It
>> contains the VLAN ID and the Ethernet MAC address of the group.
>
> I'm just trying to avoid the use of 'multicast group' for a L2 entity,
> unless it is already widespread used so in the bridge code. If the
> bridge code does consider L2 a 'multciast group', fine, lets document
> it so. But if the bridge code only uses 'multciast group' to mean L3,
> we should not use it here for L2.

I am not quite sure about that. I can see that SWITCHDEV_OBJ_ID_PORT_MDB
is only crafted in net/bridge/br_mdb.c:__br_mdb_notify().

What should we do if the bridge code consider a multicast group as L3?

Thanks,

        Vivien
