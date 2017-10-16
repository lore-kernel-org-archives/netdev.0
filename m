From: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 14:56:14 +0200
Message-ID: <4d648492-39db-a729-85c8-7acd7950cc6b@prevas.dk>
References: <20171016104525.26810-1-mnhu@prevas.dk>
 <20171016123233.GD4255@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.prevas.se ([62.95.78.3]:22002 "EHLO mail01.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752080AbdJPM4O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 08:56:14 -0400
In-Reply-To: <20171016123233.GD4255@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-16 14:32, Andrew Lunn wrote:
> On Mon, Oct 16, 2017 at 12:45:25PM +0200, Martin Hundebøll wrote:
>> When configuring a switch port to use an external phy, the phy is
>> connected to external switch MII bus:
> 
> So this is a 6390?

6390X

> So this used to work. I have a 10G phy connected to the external MII
> bus on a 6390. I wonder when this got broken? Supporting phy-handle is
> old code, so when i added the external MII i don't think i needed to
> change any generic code.

I had debug printing verifying that the external phy got registered with 
mdiobus_register_device(), and that dsa_slave_phy_connect() looked in 
the wrong mdio_map[].

// Martin
