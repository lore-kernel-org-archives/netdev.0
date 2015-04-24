From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Thu, 23 Apr 2015 21:40:29 -0700
Message-ID: <CAF2d9jhR8ThpBC_xHsF+rE46FxY_Eew_VSRZOXFtc66m9ZeXbg@mail.gmail.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
 <1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAF2d9jgBwgLzg3y9KDaVHmbE7_NYnHVjTPfD=Jw-yAbLGGhe7w@mail.gmail.com> <20150424.002836.1182213850465198590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eric.dumazet@gmail.com, linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36514 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbbDXEku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 00:40:50 -0400
Received: by oift201 with SMTP id t201so31774421oif.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 21:40:49 -0700 (PDT)
In-Reply-To: <20150424.002836.1182213850465198590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 9:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Thu, 23 Apr 2015 19:54:29 -0700
>
>> On Thu, Apr 23, 2015 at 5:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:
>>>
>>>> +static void ipvlan_multicast_enqueue(struct ipvl_port *port,
>>>> +                                  struct sk_buff *skb)
>>>> +{
>>>> +     if (skb->protocol == htons(ETH_P_PAUSE))
>>>> +             return;
>>>
>>> But what happens to this packet ? It seems leaked ?
>>>
>> Hmm, will take care of it in v2.
>
> Please also provide a proper "[PATCH 0/3] " introduction posting
> stating what the patch series is doing, and why.
>
Will do.

> Thanks.
