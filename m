From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Tue, 20 Sep 2016 14:23:24 -0700
Message-ID: <064d43fb-2942-efd2-6dc7-09f47a256691@gmail.com>
References: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
 <1474358360-29901-2-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, john@phrozen.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35214 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbcITVX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 17:23:27 -0400
Received: by mail-pf0-f175.google.com with SMTP id z123so11246111pfz.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 14:23:26 -0700 (PDT)
In-Reply-To: <1474358360-29901-2-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2016 12:59 AM, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> adds PHY-mode "trgmii" as an extension for the operation
> mode of the PHY interface, TRGMII can be compatible with
> RGMII, so the extended mode doesn't really have effects on
> the target MAC and PHY, is used as the indication if the
> current MAC is connected to an internal switch or external
> PHY respectively by the given configuration on the board and
> then to perform the corresponding setup on TRGMII hardware
> module.

Based on my googling, it seems like Turbo RGMII is a Mediatek-specific
thing for now, but this could become standard and used by other vendors
at some point, so I would be inclined to just extend the phy-mode
property to support trgmii as another interface type.

If you do so, do you also mind proposing an update to the Device Tree
specification:

https://www.devicetree.org/specifications/

Thanks!
-- 
Florian
