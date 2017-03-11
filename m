From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/14] net: dsa: mv88e6xxx: rework ATU Load/Purge
Date: Sat, 11 Mar 2017 15:55:39 -0500
Message-ID: <87zigrzg6s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com> <20170309233324.18539-5-vivien.didelot@savoirfairelinux.com> <20170310022748.GI22101@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54290 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdCKU4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 15:56:48 -0500
In-Reply-To: <20170310022748.GI22101@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Thu, Mar 09, 2017 at 06:33:14PM -0500, Vivien Didelot wrote:
>> All Marvell switch chips have an ATU accessed using the same Global (1)
>> register layout. Only the handling of the FID differs as more bits were
>> necessary to support more and more databases.
>> 
>> Add and use a fresh documented implementation of the ATU Load/Purge.
>
> This is not really the Linux way of doing something. You don't throw
> something away and replace it. You incrementally modify what you have
> into something better.
>
> I really wished you had moved the code, unmodified, into
> global1_atu.c. Then made lots of easy to review small changes. I
> cannot just look at this patch and know it is correct. What i need to
> compare against is not in this patch. So it is a lot harder to review.

I've addressed all of your comments in this patchset except this one.

A patch file cannot guarantee that a chunk of code moved around has not
been altered in the process. This will just generate more diff for no
value, that needs to be updated afterwards anyway.

Plus you already complained in the first iteration I sent about
modifying lines that I previously added. I took care of logically
splitting the new ATU Load/Purge, GetNext, Flush and Remove operations
into incremental unmodified chunks in this series.

I have updated the commit messages to detail the addition of the static
helpers and their counterparts, but I will resend this patch as is.

Thanks,

        Vivien
