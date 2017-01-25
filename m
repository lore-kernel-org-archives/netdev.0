From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 11:30:06 -0800
Message-ID: <CAC15z3jbwguvrVCKGA_zC40Nqm9LBx=yqHv-P+5TcWuk-w6w7Q@mail.gmail.com>
References: <20170125.122205.9460825196595773.davem@davemloft.net>
 <20170125175458.GF23545@1wt.eu> <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
 <20170125.140333.788366320476056385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36252 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdAYTaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:30:07 -0500
Received: by mail-qt0-f193.google.com with SMTP id l7so33254679qtd.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 11:30:07 -0800 (PST)
In-Reply-To: <20170125.140333.788366320476056385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Note that I am not sure we correctly test that a second connect() can be
> done, and I am not sure kernel would check that the remote IP and
> destination port is the same.

> Ie what should happen for

> setsockopt(fd, SOL_TCP, TCP_FASTOPEN_CONNECT, &on, 4)
> connect(fd,  "1.2.3.4:80")
> connect(fd, "55.66.77.88:4000")

I wrote a simple code to test this scenario and the second connect()
returns EISCONN as well even though the destination IP is different.

On Wed, Jan 25, 2017 at 11:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <tracywwnj@gmail.com>
> Date: Wed, 25 Jan 2017 10:54:50 -0800
>
>>> Yes sorry David, for me it's OK. If Wei runs his whole series of tests
>>> on it again, it should be perfect.
>>
>> I just ran all the TFO related tests with Willy's patch on top of this
>> patch series.
>> And everything passes.
>
> Great, I'll apply everything, thanks.
