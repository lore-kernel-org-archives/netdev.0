From: carl h <heyen2000@gmail.com>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 10:52:17 -0400
Message-ID: <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
References: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
 <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com> <20170501143703.GA1285@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:32794 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756286AbdEAOwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:52:20 -0400
Received: by mail-lf0-f41.google.com with SMTP id 88so61203755lfr.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 07:52:19 -0700 (PDT)
In-Reply-To: <20170501143703.GA1285@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet hardware *is* a 2 port switch in a phone which does support
vlan tag insertion in the switch and driver. The driver is third party which
I'm trying to get working with vlans.

But i can't see how the vlan info propagates down to the switch driver.





On Mon, May 1, 2017 at 10:37 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > By what mechanism does the vlan driver (8021q.ko) tell the Ethernet
>> > hardware about a vlan?
>
> Why would the Ethernet hardware need to know?
>
> An Ethernet Switch might need to know. If so, then switchdev would be
> used, include/net/switchdev.h
>
>     Andrew
