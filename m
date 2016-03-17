From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 16:33:05 +0100
Message-ID: <CAGm1_kvC3DXWOVxS7rRmFOPOEWHt9i1jc2J2a23kAKb1ZqeytA@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch> <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
 <20160316230505.GA18161@lunn.ch> <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
 <20160317134134.GA24913@lunn.ch> <CAGm1_kvJn0Pq38iqOmOcyNpe62EEUmq_s5G2_HXps4Gx+xB_=Q@mail.gmail.com>
 <20160317151240.GD26019@lunn.ch> <CAGm1_kt+d7HooYi5JgHvkVYEKO0JLn=1nBgdUd1bSG08+ZLiRg@mail.gmail.com>
 <20160317152836.GE26019@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "shaohui ???" <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:34320 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcCQPd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 11:33:26 -0400
Received: by mail-vk0-f43.google.com with SMTP id e185so106545941vkb.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 08:33:25 -0700 (PDT)
In-Reply-To: <20160317152836.GE26019@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 4:28 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > You should however consider writing a DSA driver for the switch.
>>
>> Do you mean SWITCHDEV or is this more or less the same? From time to
>> time I'm looking at DSA/switchdev patches in the mailing list, but
>> there seems to be not so many example in kernel. What are the latest
>> slides, papers aside from Documentation/networking/switchdev.txt?
>
> I don't have access to the datasheet for this device. So i've no idea
> how easy/hard it would be.
>
> Documentation/networking/switchdev.txt and
> Documentation/networking/dsa/dsa.txt would be a good place to start.
>
> The mv88e6060.c is the simplest driver and gives you the minimum you
> need to start with. Looking at the marketing brief, it looks like the
> device can do more. But it is best to start simple, get the minimal
> accepted, and then incrementally add more.

Will do. Thanks.

Yegor
