From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Mon, 22 Aug 2016 11:39:07 -0400
Message-ID: <87inusbyp0.fsf@ketchup.mtl.sfl>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch> <1471874464-16142-4-git-send-email-andrew@lunn.ch> <87zio47t7s.fsf@ketchup.mtl.sfl> <20160822150745.GC16229@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53687 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756056AbcHVPjL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 11:39:11 -0400
In-Reply-To: <20160822150745.GC16229@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Aug 22, 2016 at 10:51:03AM -0400, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> > The PPU method of accessing PHYs makes use of a timer. Make sure this
>> > timer is deleted before unloading the driver.
>> >
>> > Reported-by: Jamie Lentin <jm@lentin.co.uk>
>> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>> 
>> I'm wondering if the PPU shouldn't be disabled before unloading the
>> module...
>
> Humm, i did not thing about that.
>
> Actually, we have a general issue here. On unload, we leave the switch
> 'running'. The SF2 driver disables all the ports. The b53 seems to
> leave the switch running.

That is true. We also certainly want to put the common logic in the DSA
layer.

> We should define a general policy about this, and implement it in all
> drivers. As such, your comment is valid, but a different patch set.

I agree, that's why I added my tag to that patch ;-)

Thanks,

        Vivien
