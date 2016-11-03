From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: Check for fullsock in sock_i_uid()
Date: Fri, 4 Nov 2016 02:34:32 +0900
Message-ID: <CAKD1Yr2iC-=f_jwmdmWcfkakgjjyZfj41o78FKJ8nwFSKsGi5A@mail.gmail.com>
References: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
 <1478075943.7065.361.camel@edumazet-glaptop3.roam.corp.google.com>
 <f77e1a0d37ef82933503018a974cc07a@codeaurora.org> <1478107107.7065.379.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34991 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759575AbcKCRex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:34:53 -0400
Received: by mail-yw0-f173.google.com with SMTP id h14so56891306ywa.2
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:34:53 -0700 (PDT)
In-Reply-To: <1478107107.7065.379.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2016 at 2:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Lorenzo, have'nt you already fixed all these bugs ?

Not yet. There's still a fair bit of out-of-tree code left. Other than
per-UID routing, xt_qtaguid is the big one, but there's also xt_quota2
and xt_idletimer. to fix.

> if (skb && skb->sk)
>         timer->uid = from_kuid_munged(current_user_ns(),
>                                  sock_i_uid(skb_to_full_sk(skb)));

Thanks! I didn't know about skb_to_full_sk.
