From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Sun, 28 Aug 2016 00:50:48 -0400 (EDT)
Message-ID: <20160828.005048.1178621280768183048.davem@davemloft.net>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
        <20160826.212939.1362447220540461922.davem@davemloft.net>
        <57C186FF.6090702@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org, f.fainelli@gmail.com,
        LinoSanfilippo@gmx.de
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbcH1EvA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 00:51:00 -0400
In-Reply-To: <57C186FF.6090702@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Sat, 27 Aug 2016 07:26:39 -0500

> David Miller wrote:
>> From: Timur Tabi <timur@codeaurora.org>
>> Date: Thu, 25 Aug 2016 16:39:03 -0500
>>
>>> +static const u8 duuid[] = {
>>> +	0x77, 0x79, 0x60, 0xbf,
>>> +	0x2d, 0xab,
>>> +	0x9d, 0x4b,
>>> +	0x94, 0xf0,
>>> +	0xe1, 0x11, 0x98, 0x01, 0xa2, 0xba
>>> +};
>>
>> This seems to be completely unused, please remove it.
> 
> Sorry, I missed that during my cleanup.  I'll remove it in v10.
> 
> I wonder why my compiler didn't complain about the unused static.

Unused static "const" is not warned about.
