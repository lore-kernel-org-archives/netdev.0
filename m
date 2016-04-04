From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/4] udp: support SO_PEEK_OFFSET
Date: Mon, 4 Apr 2016 18:23:25 -0400
Message-ID: <CAF=yD-KNOafVon6LSVD+R4nLZT=j0Wdp8HJZ6skwpNdpaE1qkw@mail.gmail.com>
References: <1459726193-20863-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <20160404.174947.926111909781290127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Sam Kumar <samanthakumar@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33630 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcDDWYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 18:24:08 -0400
Received: by mail-lf0-f67.google.com with SMTP id r62so13424191lfd.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 15:24:06 -0700 (PDT)
In-Reply-To: <20160404.174947.926111909781290127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2016 at 5:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Sun,  3 Apr 2016 19:29:49 -0400
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Support peeking at a non-zero offset for UDP sockets. Match the
>> existing behavior on Unix datagram sockets.
>>
>> 1/4 makes the sk_peek_offset functions safe to use outside locks
>> 2/4 removes udp headers before enqueue, to simplify offset arithmetic
>> 3/4 introduces SO_PEEK_OFFSET support
>> 4/4 moves sk->sk_peek_off on read, to match Unix socket semantics.
>
> I don't see how you can separate patches #3 and #4.
>
> Once you hook up the socket operation, the user can successfully use
> the feature and therefore must receive the full set of semantics.

Okay, I'll squash the two patches.
