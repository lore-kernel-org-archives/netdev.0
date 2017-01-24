From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Tue, 24 Jan 2017 22:00:10 +0100
Message-ID: <87a8ag2mxx.fsf@free-electrons.com>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
        <1484955062-26718-6-git-send-email-andrew@lunn.ch>
        <87ziildzrc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:42626 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdAXVAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:00:22 -0500
In-Reply-To: <87ziildzrc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
        (Vivien Didelot's message of "Fri, 20 Jan 2017 19:26:31 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,
 
 On sam., janv. 21 2017, Vivien Didelot <vivien.didelot@savoirfairelinux.com> wrote:

> Hi Andrew,
>
> Andrew Lunn <andrew@lunn.ch> writes:
>
>> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
>> calls to the ID register, and if it is zero, return the ID for the
>> mv88e6390. The Marvell PHY driver can then bind to this ID.
>
> This, in addition to the temperature code not working (despite what the
> datasheet says) makes me wonder if this is intentional from Marvell. Do
> we have a revision number for the 88E6390X's on the ZII Dev Rev C board?
>
> It would be interesting to ask Gregory maybe about that. This looks not
> "production-ready".

What I can say is that with the 88E6341, which seems to have the same
issue (ie incomplete PHY ID), reading the temperature worked.

Gregory

>
> Other than that, I have no objection on the patch itself if that is
> indeed expected from them...
>
> Thanks,
>
>         Vivien

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
