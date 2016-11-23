From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE registers
Date: Wed, 23 Nov 2016 21:08:00 +0100
Message-ID: <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com> <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:35373 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933996AbcKWUIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 15:08:21 -0500
In-Reply-To: <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 6:33 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/23/2016 06:38 AM, yegorslists@googlemail.com wrote:
>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>
>> Add the ability to query and set Energy Efficient Ethernet parameters
>> via ethtool for applicable devices.
>
> Are you sure this is enough to actually enable EEE? I don't see where
> phy_init_eee() is called here, nor is the cpsw Ethernet controller part
> configured to enable/disable EEE. EEE is not just a PHY thing, it
> usually also needs to be configured properly at the Ethernet MAC/switch
> level as well.
>
> Just curious here.

I'm sure I want to disable EEE :-) So I need this patch in order to
check and disable EEE advertising.

Yegor
