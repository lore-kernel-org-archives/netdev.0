From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 13:15:34 -0500
Message-ID: <87efz5q5dl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com> <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com> <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170210180640.GJ2103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>, maowenan@huawei.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43670 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbdBJS1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:27:04 -0500
In-Reply-To: <20170210180640.GJ2103@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> David will at some point merge net into net-next.

Yes I know that, I just wasn't sure if having such crash in net-next was
tolerated or not. Cherry-picking 6d9f66ac7fec does the job on my side.

> Until then, you can work around the issue by enabling the PHY drivers
> for you hardware. You are also likely to gain a few nice features,
> like PHY interrupts rather than polling, maybe some temperature
> sensors, PHY statistics, etc...

Hum I have CONFIG_MARVELL_PHY enabled, am I missing something?

Thanks,

        Vivien
