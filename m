From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 0/3] add support for RGMII on GMAC0 through
 TRGMII hardware module
Date: Thu, 22 Sep 2016 20:08:47 +0300
Message-ID: <b2157c96-0b5c-5b7a-31c2-9eb4df71c73d@cogentembedded.com>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
 <20160922.082247.198689057396545219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        andrew@lunn.ch, f.fainelli@gmail.com, keyhaede@gmail.com,
        objelf@gmail.com
To: David Miller <davem@davemloft.net>, sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35427 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965319AbcIVRIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:08:51 -0400
Received: by mail-lf0-f52.google.com with SMTP id l131so74307699lfl.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 10:08:50 -0700 (PDT)
In-Reply-To: <20160922.082247.198689057396545219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/22/2016 03:22 PM, David Miller wrote:

>> By default, GMAC0 is connected to built-in switch called
>> MT7530 through the proprietary interface called Turbo RGMII
>> (TRGMII). TRGMII also supports well for RGMII as generic external
>> PHY uses but requires some slight changes to the setup of TRGMII
>> and doesn't have well support on current driver.
>>
>> So this patchset
>> 1) provides the slight changes of the setup for RGMII can work
>>    through TRGMII
>> 2) adds additional setting "trgmii" as PHY_INTERFACE_MODE_TRGMII
>>    about phy-mode on device tree to make GMAC0 distinguish which
>>    mode it runs
>> 3) changes dynamically source clock, TX/RX delay and interface
>>    mode on TRGMII for adapting various link
>>
>> Changes since v1:
>> - fixed the style of comment which doesn't have a space at
>>    the beginning and end of comment lines
>> - add support for phy-mode "trgmii" as PHY_INTERFACE_MODE_TRGMII
>>    into linux/phy.h
>> - enhance the Documentation about device tree binding for trgmii
>>   which is applicable only for GMAC0 which uses fixed-link
>
> Series applied.

    Despite my comments? Sigh...

MBR, Sergei
