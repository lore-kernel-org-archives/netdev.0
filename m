From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] tcp: fix access to sk->sk_state in tcp_poll()
Date: Wed, 26 Apr 2017 10:24:06 -0700
Message-ID: <CAEA6p_C1_3LRMPy7yaBiGf0YSsTZMfC3L4TLixyiGVyn_W1s=w@mail.gmail.com>
References: <0a1710138c3e55c388a52dba817b2d1b1996c899.1493226034.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:36330 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdDZRYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:24:07 -0400
Received: by mail-vk0-f45.google.com with SMTP id q78so4212499vke.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:24:07 -0700 (PDT)
In-Reply-To: <0a1710138c3e55c388a52dba817b2d1b1996c899.1493226034.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 10:07 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> avoid direct access to sk->sk_state when tcp_poll() is called on a socket
> using active TCP fastopen with deferred connect. Use local variable
> 'state', which stores the result of sk_state_load(), like it was done in
> commit 00fd38d938db ("tcp: ensure proper barriers in lockless contexts").
>
> Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Acked-by: Wei Wang <weiwan@google.com>
Thanks for the fix.
