From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] packet: avoid panic in packet_getsockopt()
Date: Fri, 20 Oct 2017 18:11:08 -0700
Message-ID: <CANn89iKMj3wOXV28RhZ59hrBVUNhUbcadKJSxfDhpVUKkPTN_w@mail.gmail.com>
References: <1508364504.31614.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171021.015008.162706023967923091.davem@davemloft.net> <20171021.015320.1529021296296615087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:57015 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753166AbdJUBLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 21:11:09 -0400
Received: by mail-yw0-f169.google.com with SMTP id l32so7837984ywh.13
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 18:11:09 -0700 (PDT)
In-Reply-To: <20171021.015320.1529021296296615087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 5:53 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 21 Oct 2017 01:50:08 +0100 (WEST)
>
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 18 Oct 2017 15:08:24 -0700
>>
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> syzkaller got crashes in packet_getsockopt() processing
>>> PACKET_ROLLOVER_STATS command while another thread was managing
>>> to change po->rollover
>>>
>>> Using RCU will fix this bug. We might later add proper RCU annotations
>>> for sparse sake.
>>>
>>> Fixes: a9b6391814d5 ("packet: rollover statistics")
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>
>> Applied and queued up for -stable, but:
>>
>>> Willem de Bruijn <willemb@google.com>
>>
>> I didn't know what kind of tag you intended to use here for Willem
>> so just deleted the line.
>
> I just noticed 'v2' of this patch and replaced it in time before I
> pushed out :-)

Nice, thanks again !
