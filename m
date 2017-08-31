From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: prepare (struct ubuf_info)->refcnt conversion
Date: Thu, 31 Aug 2017 18:35:06 -0400
Message-ID: <CAF=yD-KeO=4G5skswqR2r+zv1C3QshA_gZi5vZ50Nd66OcRpLQ@mail.gmail.com>
References: <20170831203013.9219-1-edumazet@google.com> <20170831203013.9219-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35666 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdHaWfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:35:50 -0400
Received: by mail-oi0-f65.google.com with SMTP id n18so533756oig.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:35:50 -0700 (PDT)
In-Reply-To: <20170831203013.9219-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 4:30 PM, Eric Dumazet <edumazet@google.com> wrote:
> In order to convert this atomic_t refcnt to refcount_t,
> we need to init the refcount to one to not trigger
> a 0 -> 1 transition.
>
> This also removes one atomic operation in fast path.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks, Eric.
