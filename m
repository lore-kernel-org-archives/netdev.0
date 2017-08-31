From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] net: convert (struct ubuf_info)->refcnt
 to refcount_t
Date: Thu, 31 Aug 2017 19:55:30 -0400
Message-ID: <CAF=yD-JMATnR-JR9W4=gJKNuZrO17fSh9KLJtBakCajwEr5bDQ@mail.gmail.com>
References: <20170831234822.26612-1-edumazet@google.com> <20170831234822.26612-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33458 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdHaX4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:56:11 -0400
Received: by mail-oi0-f65.google.com with SMTP id t124so975117oih.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:56:11 -0700 (PDT)
In-Reply-To: <20170831234822.26612-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 7:48 PM, Eric Dumazet <edumazet@google.com> wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> v2: added the change in drivers/vhost/net.c as spotted
> by Willem.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
