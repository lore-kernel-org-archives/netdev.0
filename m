From: Sriram V <vshrirama@gmail.com>
Subject: Re: Autoneg off in TI cpsw driver
Date: Fri, 17 Feb 2017 00:31:12 +0530
Message-ID: <CAH9_wRMwFdMrbK9fBKwmBxpDkj2m8X3hqN9RcXbrpmf3muo_Kw@mail.gmail.com>
References: <CAH9_wRMwiZA6GxdwMbOZjs-t-hnMaCRB1RSQ6nGoLOUJ+PxzRw@mail.gmail.com>
 <20170216185729.GC6096@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:35546 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932379AbdBPTBO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 14:01:14 -0500
Received: by mail-vk0-f49.google.com with SMTP id x75so16179977vke.2
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 11:01:13 -0800 (PST)
In-Reply-To: <20170216185729.GC6096@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

1. run ethtool -s eth1 speed 10 duplex full autoneg off
2. ethtool eth1 <-------------- shows link up

3. remove cable    <------- ethtool shows link down
4. plug it in.  <----------  ethtool Still shows link down

I don't have the ip utility. I will cross compile it and get back to you.

Thanks,
Sriram



On Fri, Feb 17, 2017 at 12:27 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Fri, Feb 17, 2017 at 12:01:32AM +0530, Sriram V wrote:
>> Hi,
>>
>> I am using a Linux Kernel 4.1 Kernel. on AM437X with dual emac configuration.
>>
>> What i find is if i do the following the Link does not come up.
>>
>> 1. run ethtool -s eth1 speed 10 duplex full autoneg off
>> 2. remove cable
>> 3. plug it in.
>>
>> With the above sequence. The link does not come up. the plug in is not detected
>
> Hi Sriram
>
> There are a few different layers involved in this, we need to
> determine which layer is unhappy.
>
> What does ethtool show?
>
> What does ip link show indicate?
>
>      Andrew
