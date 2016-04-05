From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/3] udp: support SO_PEEK_OF
Date: Tue, 5 Apr 2016 12:43:13 -0400
Message-ID: <CAF=yD-La3JRo4heRH6EUeTXsk2sJoqLNXAai5z08OL1Yzbyejw@mail.gmail.com>
References: <1459874301-92389-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Sam Kumar <samanthakumar@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33584 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbcDEQnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:43:55 -0400
Received: by mail-lf0-f67.google.com with SMTP id r62so1865225lfd.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:43:54 -0700 (PDT)
In-Reply-To: <1459874301-92389-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Support peeking at a non-zero offset for UDP sockets. Match the
> existing behavior on Unix datagram sockets.
>
> 1/3 makes the sk_peek_offset functions safe to use outside locks
> 2/3 removes udp headers before enqueue, to simplify offset arithmetic
> 3/3 introduces SO_PEEK_OFFSET support, with Unix socket peek semantics.

Please ignore this cover letter. I sent it to soon. It is superseded
by a v2 patch set.
