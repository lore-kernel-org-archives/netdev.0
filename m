From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1.1] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Mon, 27 Feb 2017 14:54:47 -0500 (EST)
Message-ID: <20170227.145447.1005420963599745103.davem@davemloft.net>
References: <d32546b59c67456c77d003af1df51862d2f8c5de.1487617501.git.chunkeey@googlemail.com>
        <20170222.153735.1289514443979947868.davem@davemloft.net>
        <2567253.1QjLrx0r05@debian64>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        ivan@de.ibm.com, f.fainelli@gmail.com, andrew@lunn.ch,
        robh+dt@kernel.org
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdB0UPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 15:15:05 -0500
In-Reply-To: <2567253.1QjLrx0r05@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Mon, 27 Feb 2017 20:42:15 +0100

> On Wednesday, February 22, 2017 3:37:35 PM CET David Miller wrote:
>> From: Christian Lamparter <chunkeey@googlemail.com>
>> Date: Mon, 20 Feb 2017 20:10:58 +0100
>> 
>> > This patch adds glue-code that allows the EMAC driver to interface
>> > with the existing dt-supported PHYs in drivers/net/phy.
>> > 
>> > Because currently, the emac driver maintains a small library of
>> > supported phys for in a private phy.c file located in the drivers
>> > directory.
>> > 
>> > The support is limited to mostly single ethernet transceiver like the:
>> > CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
>> > 
>> > However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
>> > have a 5-port switch (AR8327N) attached to the EMAC. The switch chip
>> > is supported by the qca8k mdio driver, which uses the generic phy
>> > library. Another reason is that PHYLIB also supports the BCM54610,
>> > which was used for the Western Digital My Book Live.
>> > 
>> > This will now also make EMAC select PHYLIB.
>> > 
>> > Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
>> 
>> Applied, thanks.
>> 
> Thanks David.
> 
> I noticed that the DT Documentation patch:
> "[v1,1/2] dt: emac: document device-tree based phy discovery and setup"
> is still pending with "Changes Requested":
> <https://patchwork.ozlabs.org/patch/729658/>
> 
> I think this is because of Florian's comment on patch:
> "[v1,2/2] net: emac: add support for device-tree based PHY discovery and setup"
> If so, can you please queue this documentation update patch for -next?
> (I haven't received any comments or complains. If necessary, I can also
> resent it.)

Please resend.
