From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH 0/5] net/packet: fix multiple overflow issues in ring buffers
Date: Tue, 28 Mar 2017 11:06:12 -0400
Message-ID: <CAF=yD-+Lx+=uXNSDPFRu0AGsaeTPsH=uuDvBdFQg=oH7vmuB6g@mail.gmail.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:36017 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbdC1PHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:07:14 -0400
Received: by mail-qt0-f170.google.com with SMTP id r45so66438203qte.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:07:08 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> This patchset addresses multiple overflows and signedness-related issues
> in packet socket ring buffers.
>
> Andrey Konovalov (5):
>   net/packet: fix overflow in check for priv area size
>   net/packet: add explicit checks for tp_frame_size
>   net/packet: fix overflow in check for tp_frame_nr
>   net/packet: fix overflow in check for tp_reserve
>   net/packet: reorder checks for ring buffer parameters

These are a lot of changes to backport to stable kernels.

Can we separate the minimal patch set needed to address known overflow
to send to net (with annotation [PATCH net]) and follow up with the larger
cleanup to net-next.

>
>  net/packet/af_packet.c | 31 +++++++++++++++++++++----------
>  1 file changed, 21 insertions(+), 10 deletions(-)
>
> --
> 2.12.2.564.g063fe858b8-goog
>
