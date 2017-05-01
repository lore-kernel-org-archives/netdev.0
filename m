From: carl h <heyen2000@gmail.com>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 14:26:52 -0400
Message-ID: <CABM+yxnbLPjoq4E2Z3d2Jc5qUvN_TWUb6rQpjDWCTs=9j0ce3A@mail.gmail.com>
References: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
 <20170501143703.GA1285@lunn.ch> <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
 <20170501.105736.157375316602250235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34744 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbdEAS0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:26:55 -0400
Received: by mail-lf0-f54.google.com with SMTP id t144so63860912lff.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 11:26:54 -0700 (PDT)
In-Reply-To: <20170501.105736.157375316602250235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that the switchdev driver model was introduced after 2.6.39
which is the
kernel version that I'm using unfortunately.

So considering this, and the fact that the switch hardware I'm using has support
for vlan tag insertion, how would it have been accomplished for my version
of the kernel?

Also is it possible to get the vlan driver to insert the vlan tags for
each packet? If so
how can that be accomplished?

Thanks
/carl


On Mon, May 1, 2017 at 10:57 AM, David Miller <davem@davemloft.net> wrote:
> From: carl h <heyen2000@gmail.com>
> Date: Mon, 1 May 2017 10:52:17 -0400
>
>> But i can't see how the vlan info propagates down to the switch driver.
>
> Which "VLAN info" are you talking about?
>
> The VLANs configured onto the device itself or the per-packet VLAN
> info.
>
> Per-device VLAN configuration is communicated to the netdev driver
> via netdev_ops->ndo_vlan_{add,kill}_vid().
>
> Per-packet VLAN information is stored in skb->vlan_{proto,tci}.
