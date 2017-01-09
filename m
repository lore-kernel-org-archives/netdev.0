From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for dsa2
Date: Mon, 09 Jan 2017 10:45:33 -0500
Message-ID: <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com> <20170109073236.GA1862@nanopsycho> <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170109151131.GC1862@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42698 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753551AbdAIPqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:46:24 -0500
In-Reply-To: <20170109151131.GC1862@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Jiri Pirko <jiri@resnulli.us> writes:

>>Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
>
> Again, phys_port_id has nothing to do with switches. Should be removed
> from dsa because its use there is incorrect.

Florian, since 3a543ef just got in, can it be reverted?

>>> I guess that it should be enough for you to implement
>>> ndo_get_phys_port_name.
>>
>>Well, if this name must be unique on a system, it's not likely to happen
>>until we agree that we use an ugly tXsYpZ template where X is a tree ID,
>>or we assign system-wide unique IDs to switches, which requires a bit of
>>changes.
>
> No. That should be unique within one switch. In mlxsw we name it "p1",
> "p2", ...
>
> The final netdev names are:
> enp3s0np1, enp3s0np2, ...

OK perfect then, "p%d" sounds good. You seems to avoid "p0" in mlxsw, is
there a reason for that?

>>But again, this is not related to this patch ;-)
>
> It is! You are using phys_port_id, which is completely wrong. You should
> not use it.

I can resend this patch without the udev examples in the commit message
if that can be less confusing.

Thanks,

        Vivien
