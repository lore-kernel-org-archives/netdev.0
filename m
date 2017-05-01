From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 00/18] net: dsa: mv88e6xxx: 802.1s and 88E6390 VTU
Date: Mon, 01 May 2017 12:21:31 -0400
Message-ID: <87shko7dkk.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com> <871ss8bmom.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170501.120800.1973590139715167836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39708 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdEAQXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:23:15 -0400
In-Reply-To: <20170501.120800.1973590139715167836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Mon, 01 May 2017 11:51:05 -0400
>
>> Hi David,
>> 
>> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
>> 
>>> Vivien Didelot (18):
>>>   net: dsa: mv88e6xxx: add max VID to info
>>>   net: dsa: mv88e6xxx: split VTU entry data member
>>>   net: dsa: mv88e6xxx: move VTU Operation accessors
>>>   net: dsa: mv88e6xxx: move VTU flush
>>>   net: dsa: mv88e6xxx: move VTU FID accessors
>>>   net: dsa: mv88e6xxx: move VTU SID accessors
>>>   net: dsa: mv88e6xxx: move VTU VID accessors
>>>   net: dsa: mv88e6xxx: move generic VTU GetNext
>>>   net: dsa: mv88e6xxx: move VTU Data accessors
>>>   net: dsa: mv88e6xxx: move STU GetNext operation
>>>   net: dsa: mv88e6xxx: get STU entry on VTU GetNext
>>>   net: dsa: mv88e6xxx: load STU entry with VTU entry
>>>   net: dsa: mv88e6xxx: add VTU GetNext operation
>>>   net: dsa: mv88e6xxx: add VTU Load/Purge operation
>>>   net: dsa: mv88e6xxx: make VTU helpers static
>>>   net: dsa: mv88e6xxx: simplify VTU entry getter
>>>   net: dsa: mv88e6xxx: support the VTU Page bit
>>>   net: dsa: mv88e6xxx: add VTU support for 88E6390
>>>
>>>  drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
>>>  drivers/net/dsa/mv88e6xxx/chip.c        | 568 +++++++++-----------------------
>>>  drivers/net/dsa/mv88e6xxx/global1.h     |  14 +
>>>  drivers/net/dsa/mv88e6xxx/global1_vtu.c | 505 ++++++++++++++++++++++++++++
>>>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  31 +-
>>>  5 files changed, 684 insertions(+), 435 deletions(-)
>>>  create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c
>> 
>> I don't see the patchset in net-next. Can you pick it?
>
> This had feedback which you must address, therefore the state in
> patchwork is "changes requested" which you could have checked before
> asking me this.
>
> If the patch set is fine and you got ACKs for all of your patches
> then please resubmit.
>
> Otherwise, make the changes you were asked to make or explain to
> the person who asked for them why they are not appropriate.

We did discuss the patchset and everything is good as is. Can someone
change the state in patchwork afterwards? It feels weird to resend the
patch with no changes.

Thanks,

        Vivien
