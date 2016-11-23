From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on mv88e6097
Date: Wed, 23 Nov 2016 13:18:31 -0500
Message-ID: <87zikqkqko.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161123165022.GD12698@gruene.netmodule.intranet> <20161123165440.4894-1-stefan.eichenberger@netmodule.com> <20161123165949.GB8760@lunn.ch> <20161123171441.GE12698@gruene.netmodule.intranet> <20161123174040.GE8760@lunn.ch> <877f7uxevf.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161123180125.GF8760@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37518 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750857AbcKWSSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 13:18:33 -0500
In-Reply-To: <20161123180125.GF8760@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Nov 23, 2016 at 12:52:52PM -0500, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> > And if you have a recent version of tcpdump, it will decode
>> > the header.
>> 
>> Since d729eb4, thanks to you Andrew ;-)
>> 
>> I move up the cleanup of ports setup in my priority list.
>
> Hi Vivien
>
> Please take a look at my mv88e6390 branch. I already refactored this
> code, because the mv88e6390 does something slightly different...
>
> I hope to post another batch of mv88e6390 patches soon, and they will
> include this cleanup. Since they will clash with these patches, i will
> post them first as RFC.

Perfect. Please split an RFC only including this cleanup if
possible. Fewer patches will be easier to review, since the first port
registers differs a lot.

Thanks,

        Vivien
