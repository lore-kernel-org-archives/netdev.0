From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Mon, 8 May 2017 14:37:41 -0700
Message-ID: <CAJieiUhyeSBk+Zm8xkZ2D24-CrgpUpBCvUORDLXX7+6yAbw-6Q@mail.gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com> <20170506160734.47084-4-dsahern@gmail.com>
 <1494233712.2562.0.camel@sipsolutions.net> <20170508.161130.1538627061428691500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
        David Ahern <dsahern@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:35091 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754527AbdEHVhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 17:37:48 -0400
Received: by mail-ua0-f178.google.com with SMTP id e55so55424493uaa.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 14:37:47 -0700 (PDT)
In-Reply-To: <20170508.161130.1538627061428691500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 1:11 PM, David Miller <davem@davemloft.net> wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 08 May 2017 10:55:12 +0200
>
>>
>>> +static inline bool netif_is_lwd(struct net_device *dev)
>>> +{
>>> +    return !!(dev->priv_flags & IFF_LWT_NETDEV);
>>> +}
>>
>> Am I the only one who thinks that this "LWT_NETDEV" vs "LWD" is a bit
>> confusing?
>
> Agreed, my old eyes can't discern them at a distance :-)


agree.

mix of LWT_NETDEV and LWD can get confusing.

LWT already stands for Light Weight Tunnel...,
this can only be LWD or  LWN ;)....if people don't confuse it with
some weekly news device :)
