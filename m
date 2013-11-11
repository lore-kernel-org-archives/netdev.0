From: Mark Trompell <mark@foresightlinux.org>
Subject: Re: bridge not getting ip since 3.11.5 and 3.4.66
Date: Mon, 11 Nov 2013 13:52:13 +0100
Message-ID: <CAEPa5y=tgdGpDMBGY0ijyWSgQ0m5SZW8EMP072OF=sZZUjqN1g@mail.gmail.com>
References: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
	<CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <veaceslav@falico.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:49930 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab3KKMwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:52:15 -0500
Received: by mail-bk0-f47.google.com with SMTP id v11so1236664bkz.6
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 04:52:14 -0800 (PST)
In-Reply-To: <CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 12:07 PM, Veaceslav Falico <veaceslav@falico.eu> wrote:
> On Mon, Nov 11, 2013 at 11:29 AM, Mark Trompell <mark@foresightlinux.org> wrote:
>> my bridge br0 doesn't get an ip from dhcp anymore after 3.11.5 and 3.4.66,
>> What information would be helpful and required to find out what's going wrong.
>
> CC netdev
>
> First thing would be to provide the network scheme. Do you use vlans?
> Which network
> cards/drivers are you using? Do you use some kind of virtualization?
> Is bonding involved?
>
Actually this is my desktop machine using kvm for a virtual machine
that uses eth0 which is connected to the bridge
which is used as interface for the host.

$ ip addr
2. eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast
master br0 qlen 1000
...
3. br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
...

Anything else?

Greetings
Mark
