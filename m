From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 8/8] tcp: tsq: move tsq_flags close to sk_wmem_alloc
Date: Sun, 4 Dec 2016 18:45:42 -0800
Message-ID: <CANn89iKLmzxF+NFurgFRn2yYFAJxi7nbVtkCyadE2Be6x8SR5g@mail.gmail.com>
References: <1480792497-16607-9-git-send-email-edumazet@google.com>
 <20161203.191626.976921736888291388.davem@davemloft.net> <1480814031.18162.439.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161203.203708.151248945683979245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36278 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbcLECpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 21:45:44 -0500
Received: by mail-io0-f177.google.com with SMTP id m5so437019759ioe.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 18:45:44 -0800 (PST)
In-Reply-To: <20161203.203708.151248945683979245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 3, 2016 at 5:37 PM, David Miller <davem@davemloft.net> wrote:

>
> Sorry, just noticed by visual inspection.  I expected the
> struct sock part to show up in the same patch as the one
> that removed it from tcp_sock and adjusted the users.
>
> I'll re-review this series, thanks.

Yes, I wanted to have after patch 7, the final cache line disposition
of struct sock.
(Quite critical for future bisections if needed, or performance tests
I mentioned)

I could have used a 'unsigned long _temp_padding', but just chose the
final name for the field.

Thanks.
