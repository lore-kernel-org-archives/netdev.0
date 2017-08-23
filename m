From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] net/sock: allow the user to set negative peek offset
Date: Wed, 23 Aug 2017 09:01:59 -0400
Message-ID: <CAF=yD-+GfJLTj=O4w_eAheO-kzOuuUanaQNEsSZ=rRqcnvmbjg@mail.gmail.com>
References: <64e676e59d203f13cd326c3b0cf6b05287b69e1b.1503481941.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Matthew Dawson <matthew@mjdsystems.ca>,
        Sam Kumar <samanthakumar@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34815 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbdHWNCl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 09:02:41 -0400
Received: by mail-oi0-f67.google.com with SMTP id k62so53143oia.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 06:02:41 -0700 (PDT)
In-Reply-To: <64e676e59d203f13cd326c3b0cf6b05287b69e1b.1503481941.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 5:57 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> This is necessary to allow the user to disable peeking with
> offset once it's enabled.
> Unix sockets already allow the above, with this patch we
> permit it for udp[6] sockets, too.
>
> Fixes: 627d2d6b5500 ("udp: enable MSG_PEEK at non-zero offset")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Willem de Bruijn <willemb@google.com>

I don't think that the existing behavior is buggy, per se. So this
could also go to net-next.
