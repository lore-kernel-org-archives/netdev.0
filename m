From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 9/9] mlx4: add page recycling in receive path
Date: Tue, 7 Feb 2017 08:34:45 -0800
Message-ID: <CANn89iLVDLmnLU-CpLag=Rh31HgsaYE6JV--r+=Ahoc3QDwF8w@mail.gmail.com>
References: <20170207030240.31357-1-edumazet@google.com> <20170207030240.31357-10-edumazet@google.com>
 <92a6e32b-6f0a-88a6-52d3-6ca352c26b22@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33801 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754663AbdBGQer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:34:47 -0500
Received: by mail-io0-f182.google.com with SMTP id l66so94300478ioi.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:34:46 -0800 (PST)
In-Reply-To: <92a6e32b-6f0a-88a6-52d3-6ca352c26b22@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 8:20 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>
>
> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
>>
>> Same technique than some Intel drivers, for arches where PAGE_SIZE = 4096
>>
>> In most cases, pages are reused because they were consumed
>> before we could loop around the RX ring.
>
> This might not be true when multiple streams are handled in the same ring.
> As the process time in stack will be longer.
> We will test this scenario as well.

Sure thing. I already did ;)

I had a local patch adding a new "ethtool -S ... | grep
rx_page_allocs"  counter.

I could probably add it to the series.  (I noticed that
rx_alloc_failed was a dead counter)

Thanks.
