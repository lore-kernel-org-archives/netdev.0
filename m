From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: I find one aspect of the ip link show command confusing and I'd
 like you to fix it, please
Date: Mon, 24 Apr 2017 08:54:07 -0700
Message-ID: <20170424085407.2b9df529@xeon-e3>
References: <CAGu9dLLRVaiO-vHd_jzVuMM3O=sjLX_VOeu5n6-+eV6fEdhBug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Silverman <jeffsilverm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33471 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172288AbdDXPyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:54:21 -0400
Received: by mail-pg0-f54.google.com with SMTP id 63so15081346pgh.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:54:16 -0700 (PDT)
In-Reply-To: <CAGu9dLLRVaiO-vHd_jzVuMM3O=sjLX_VOeu5n6-+eV6fEdhBug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Apr 2017 15:36:32 -0700
Jeff Silverman <jeffsilverm@gmail.com> wrote:

> People,
> 
> When my NIC is up, but not connected, I see:
> 
> root@jeff-desktop:~# ip link show enp3s0
> 2: enp3s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state
> DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:10:18:cc:9c:77 brd ff:ff:ff:ff:ff:ff
> root@jeff-desktop:~# ip link show enp3s0
> 
> NO-CARRIER makes sense to me - if the wire is unplugged, then the NIC
> isn't seeing the humm at the beginning of each packet.  That's clear.
> Note that even though my link isn't plugged in,  ip still notes that
> it is up.  That's great.
> 
> 
> But if I down my NIC, there is no indication that it is DOWN other
> than you can't see the UP flag.  If somebody was new to linux, they
> would not see what's not there.
> 
> 2: enp3s0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN mode
> DEFAULT group default qlen 1000
>     link/ether 00:10:18:cc:9c:77 brd ff:ff:ff:ff:ff:ff
> 
> 
> What I would like you to do is modify the ip command so that if the
> NIC has been downed by something, then it explicitly says DOWN.
> 
> What would be really nice would be if you enumerated all of the flags
> that an interface can have, and note if the flag is set or cleared.
> But that's more than what I want with this message.
> 
> 
> Many thanks,
> 
> 
> Jeff
> 

If you have a suggestion send a patch. The utility has shown the same
output since the earliest versions. Therefore the default output format
can't change since people do things like write scripts to parse it.
A more verbose output is possible but would have to be enabled by
a flag.
