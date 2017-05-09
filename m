From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Mon, 8 May 2017 22:04:04 -0700
Message-ID: <CAJieiUhKYB2AcSphh1pP8dpe_mdkG+2ri2SofYkEcXEgDAyMOQ@mail.gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com> <20170506160734.47084-4-dsahern@gmail.com>
 <1494233712.2562.0.camel@sipsolutions.net> <20170508.161130.1538627061428691500.davem@davemloft.net>
 <52621c1c-57c4-efb7-80dc-648a0da7ae7f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:33269 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdEIFEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 01:04:05 -0400
Received: by mail-ua0-f171.google.com with SMTP id z47so63136145uaz.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 22:04:05 -0700 (PDT)
In-Reply-To: <52621c1c-57c4-efb7-80dc-648a0da7ae7f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 5:57 PM, David Ahern <dsahern@gmail.com> wrote:
> On 5/8/17 1:11 PM, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Mon, 08 May 2017 10:55:12 +0200
>>
>>>
>>>> +static inline bool netif_is_lwd(struct net_device *dev)
>>>> +{
>>>> +   return !!(dev->priv_flags & IFF_LWT_NETDEV);
>>>> +}
>>>
>>> Am I the only one who thinks that this "LWT_NETDEV" vs "LWD" is a bit
>>> confusing?
>>
>> Agreed, my old eyes can't discern them at a distance :-)
>>
>
> perhaps it is the tiny font your old eyes are having trouble with :-)
>
> I am fine with Johannes' suggestion -- just spell it out:
>     netif_is_lwt_netdev
>
> where lwt = LightWeighT

makes sense...but this does sound like a 'light weight tunnel
netdevice' though.....just cause 'LWT' already expands to 'light
weight tunnel'
