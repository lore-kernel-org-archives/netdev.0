From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Fri, 9 Sep 2016 15:17:34 -0700
Message-ID: <CAF2d9jgM4UXRYhFt=cAcoLCW3f7zRFL7BZY6y4wjN+xo+jbjPw@mail.gmail.com>
References: <1473458010-18571-1-git-send-email-mahesh@bandewar.net> <e5cc5f33-9a78-cc0f-9244-9a3f7ed4876f@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:34831 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755105AbcIIWSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 18:18:00 -0400
Received: by mail-yb0-f177.google.com with SMTP id l4so9134421ybl.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 15:17:59 -0700 (PDT)
In-Reply-To: <e5cc5f33-9a78-cc0f-9244-9a3f7ed4876f@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 3:07 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 09/09/2016 02:53 PM, Mahesh Bandewar wrote:
>
>> @@ -48,6 +48,11 @@ master device for the L2 processing and routing from
>> that instance will be
>>  used before packets are queued on the outbound device. In this mode the
>> slaves
>>  will not receive nor can send multicast / broadcast traffic.
>>
>> +4.3 L3S mode:
>> +       This is very similar to the L3 mode except that iptables
>> conn-tracking
>> +works in this mode and that is why L3-symsetric (L3s) from iptables
>> perspective.
>> +This will have slightly less performance but that shouldn't matter since
>> you
>> +are choosing this mode over plain-L3 mode to make conn-tracking work.
>
>
> What is that first sentence trying to say?  It appears to be incomplete, and
> is that supposed to be "L3-symmetric?"
>
Apologies! Seems like I picked up wrong text file (I'll correct this
in next ver). BTW it should read -
" This is very similar to L3 mode except that iptables (conn-tracking)
works in this mode and hence it is  L3-symmetric (L3s). This will have
..."

> happy benchmarking,
>
> rick jones
