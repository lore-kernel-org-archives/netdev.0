From: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 15:16:51 +0200
Message-ID: <02997de6-1c8a-d69b-d19b-3a811288e8ed@prevas.dk>
References: <20171016104525.26810-1-mnhu@prevas.dk>
 <20171016123233.GD4255@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:60580 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751411AbdJPNQw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 09:16:52 -0400
In-Reply-To: <20171016123233.GD4255@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-16 14:32, Andrew Lunn wrote:
> So this used to work. I have a 10G phy connected to the external MII
> bus on a 6390. I wonder when this got broken? Supporting phy-handle is
> old code, so when i added the external MII i don't think i needed to
> change any generic code.

It could look like commit cd28a1a9baee7 ('net: dsa: fully divert PHY 
reads/writes if requested') changed the of-case to use the mdio bus 
associated with struct dsa_switch unconditionally.

// Martin
