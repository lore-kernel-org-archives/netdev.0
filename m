From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [RESEND PATCH net 06/10] net: ethernet: mediatek: fix the loss
Date: Mon, 29 Aug 2016 12:27:13 +0800
Message-ID: <1472444833-28693-1-git-send-email-sean.wang@mediatek.com>
References: <20160826141759.GG25046@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
        <keyhaede@gmail.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:31233 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750818AbcH2E1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 00:27:18 -0400
In-Reply-To: <20160826141759.GG25046@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Fri, 26 Aug 2016 16:17:59 +0200, Andrew Lunn wrote:
>> Hi Andrew,
>> 
>> Here pinctrl is used to setup what function the group of the pins is
>> for.
>
>Agreed.
> 
>> The group of the pins could be configured for the function provided 
>> by the SoC, such as general purpose I/O or specific function such as
>> ethernet depending on what products or boards you design for various 
>> customers or vendors. Thanks for device tree introducing, it is easy 
>> to find what resources the board needs including the pins usage is 
>> also defined here.
>
>All clear. However, if the ethernet driver has loaded, it means the
>device tree says the ethernet should be loaded, unless it happens to
>be on some discoverable bus. And so the device tree node for the
>ethernet should also contain the needed pinctrl properties.  The core
>driver code should of seen these properties and already enabled the
>correct pinctrl state before the driver probes.
>
>This is how every other driver works. Like i said, i don't think i've
>seen any other driver do its own pinctrl. So i just need a simple
>description, what is different here, why does this driver need to do
>it, when no other does?
>
>    Andrew
>

You are right
all that I need about pinctrl are all being done with core driver 
as you said, so the patch I did seems the redundant work and i will remove 
it from the patch set.

thanks for your patient and careful reviewing and that also helps me getting 
familiar with based driver with pinctrl more :)

Sean
