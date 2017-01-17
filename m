From: Tom Herbert <tom@herbertland.com>
Subject: Re: fq_codel and skb->hash
Date: Mon, 16 Jan 2017 22:18:37 -0800
Message-ID: <CALx6S34ugaCqDtE=-4533mNsPgt_T0oHC1CN0-vx_uga+ihLdQ@mail.gmail.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
 <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com> <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Collins <acollins@cradlepoint.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:33277 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdAQGSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 01:18:38 -0500
Received: by mail-qt0-f176.google.com with SMTP id v23so139770164qtb.0
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 22:18:38 -0800 (PST)
In-Reply-To: <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-01-16 at 17:44 -0800, Eric Dumazet wrote:
>> On Mon, 2017-01-16 at 17:04 -0700, Andrew Collins wrote:
>
>> >   Is there a better way to manage flow separation in routed+encapsulated traffic?
>>
>> Encapsulated traffic is fine, since flow dissector skips encap header(s)
>> up to the L4 header.
>>
>> Problem is about encrypted traffic, since presumably this L4 header is
>> opaque for flow dissector ;)
>
>
> BTW, how can we make sure skb->hash is populated before IPSEC ?
>
> Relying on forwarding, and skb->hash set by a device might be not
> enough.
>
Should we do skb_get_hash upon entry to IPsec?

Tom

>
>
