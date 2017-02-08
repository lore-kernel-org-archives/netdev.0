From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 9/9] mlx4: add page recycling in receive path
Date: Wed, 8 Feb 2017 12:27:05 +0200
Message-ID: <1486a0fa-b098-6990-2246-3a634dfd0a61@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
 <20170207030240.31357-10-edumazet@google.com>
 <92a6e32b-6f0a-88a6-52d3-6ca352c26b22@gmail.com>
 <CANn89iLVDLmnLU-CpLag=Rh31HgsaYE6JV--r+=Ahoc3QDwF8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33225 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754404AbdBHMXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 07:23:24 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so32853732wmv.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 04:22:37 -0800 (PST)
In-Reply-To: <CANn89iLVDLmnLU-CpLag=Rh31HgsaYE6JV--r+=Ahoc3QDwF8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/02/2017 6:34 PM, Eric Dumazet wrote:
> On Tue, Feb 7, 2017 at 8:20 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>>
>> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
>>> Same technique than some Intel drivers, for arches where PAGE_SIZE = 4096
>>>
>>> In most cases, pages are reused because they were consumed
>>> before we could loop around the RX ring.
>> This might not be true when multiple streams are handled in the same ring.
>> As the process time in stack will be longer.
>> We will test this scenario as well.
> Sure thing. I already did ;)
>
> I had a local patch adding a new "ethtool -S ... | grep
> rx_page_allocs"  counter.
>
> I could probably add it to the series.
I'd always like to have this kind of counters. They make performance 
analysis much easier.
>    (I noticed that
> rx_alloc_failed was a dead counter)
Yes indeed... I'll take care of it. Thanks!
>
> Thanks.
