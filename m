From: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for Mediatek MT7530 switch
Date: Wed, 24 May 2017 14:17:39 +0300
Message-ID: <hn6gvd-qp1.ln1@banana.localnet>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com> <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:44605 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1764083AbdEXLdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 07:33:22 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <linux-netdev-2@m.gmane.org>)
        id 1dDUXN-0001Uk-7w
        for netdev@vger.kernel.org; Wed, 24 May 2017 13:33:09 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In gmane.linux.kernel sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>

> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
> Mediatek router platforms such as MT7623A or MT7623N platform which
> includes 7-port Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY.
> Among these ports, The port from 0 to 4 are the user ports connecting
> with the remote devices while the port 5 and 6 are the CPU ports
> connecting into Mediatek Ethernet GMAC.

> For port 6, it can communicate with the CPU via Mediatek Ethernet GMAC
> through either the TRGMII or RGMII which could be controlled by phy-mode
> in the dt-bindings to specify which mode is preferred to use. And for
> port 5, only RGMII can be specified. However, currently, only port 6 is
> being supported in this DSA driver.

> The driver is made with the reference to qca8k and other existing DSA
> driver. The most of the essential callbacks of the DSA are already
> support in the driver, including tag insert for user port distinguishing,
> port control, bridge offloading, STP setup and ethtool operation to allow
> DSA to model each user port into a standalone netdevice as the other DSA
> driver had done.

What about JUMBO frames and large MTU support? devlink support?
