From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 10:19:47 -0800
Message-ID: <9be783d6-2686-9140-6e6c-c96044836e34@gmail.com>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
 <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
 <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170210180640.GJ2103@lunn.ch>
 <87efz5q5dl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: maowenan@huawei.com, netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35673 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdBJSUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:20:24 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so5531634qtc.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 10:19:50 -0800 (PST)
In-Reply-To: <87efz5q5dl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 10:15 AM, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> David will at some point merge net into net-next.
> 
> Yes I know that, I just wasn't sure if having such crash in net-next was
> tolerated or not. Cherry-picking 6d9f66ac7fec does the job on my side.
> 
>> Until then, you can work around the issue by enabling the PHY drivers
>> for you hardware. You are also likely to gain a few nice features,
>> like PHY interrupts rather than polling, maybe some temperature
>> sensors, PHY statistics, etc...
> 
> Hum I have CONFIG_MARVELL_PHY enabled, am I missing something?

If you have fixed PHYs they'll use Generic PHY, suddenly the dungeons
collapses, you die.
-- 
Florian
