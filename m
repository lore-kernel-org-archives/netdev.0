From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Wed, 21 Sep 2016 09:59:26 -0700
Message-ID: <b9d6deab-8763-a324-fa7b-15a9e3358ff4@gmail.com>
References: <064d43fb-2942-efd2-6dc7-09f47a256691@gmail.com>
 <1474443189-8836-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34398 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933504AbcIUQ73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 12:59:29 -0400
Received: by mail-pa0-f54.google.com with SMTP id wk8so20144804pab.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 09:59:28 -0700 (PDT)
In-Reply-To: <1474443189-8836-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2016 12:33 AM, Sean Wang wrote:
> Date: Tue, 20 Sep 2016 14:23:24 -0700, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 09/20/2016 12:59 AM, sean.wang@mediatek.com wrote:
>>> From: Sean Wang <sean.wang@mediatek.com>
>>>
>>> adds PHY-mode "trgmii" as an extension for the operation
>>> mode of the PHY interface, TRGMII can be compatible with
>>> RGMII, so the extended mode doesn't really have effects on
>>> the target MAC and PHY, is used as the indication if the
>>> current MAC is connected to an internal switch or external
>>> PHY respectively by the given configuration on the board and
>>> then to perform the corresponding setup on TRGMII hardware
>>> module.
>>
>> Based on my googling, it seems like Turbo RGMII is a Mediatek-specific
>> thing for now, but this could become standard and used by other vendors
>> at some point, so I would be inclined to just extend the phy-mode
>> property to support trgmii as another interface type.
>>
>> If you do so, do you also mind proposing an update to the Device Tree
>> specification:
>>
>> https://www.devicetree.org/specifications/
>>
>> Thanks!
> 
> I am willing to do the these thing
> 
> 1)
> in the next version, I will extend rgmii mode as
> another interface type as PHY_INTERFACE_MODE_TRGMII
> defined in linux/phy.h instead of extension only inside
> the current driver. This change also helps to save some code.
> 
> 2)
> I send another separate patch for updating the Device Tree
> specification about TRGMII adding description
> 
> are these all okay for you?

Absolutely, thanks a lot!
-- 
Florian
