From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] net: skb_needs_check() removes CHECKSUM_NONE
 check for tx.
Date: Wed, 9 Aug 2017 11:30:35 -0700
Message-ID: <CAF=yD-JjaDFy4pOeJ5Lh2em9MgK6jjNxSfc5MkZZ=L6cu9be4Q@mail.gmail.com>
References: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:37025 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHISbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:31:16 -0400
Received: by mail-oi0-f66.google.com with SMTP id j194so6443472oib.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 11:31:16 -0700 (PDT)
In-Reply-To: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 5:04 AM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
> This patch reverts the commit 6e7bc478c9a0
> ("net: skb_needs_check() accepts CHECKSUM_NONE for tx"),
> because we removed the UFO support.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>


I would wait until net is merged into net-next. This will cause a conflict.

Also, while logically equivalent, it is not a real revert (as in `git
revert $SHA1`) of that patch.

Aside from those concerns, I agree that the original patch is no
longer needed now that UFO is reverted.
