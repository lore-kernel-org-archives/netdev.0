From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: md5: increment sk_drops on syn_recv state
Date: Wed, 24 Aug 2016 11:53:53 -0400
Message-ID: <CADVnQy=z8rU1v2jzO58Gk53GzB5_K09dHoP=viQkhMhYAOZhVQ@mail.gmail.com>
References: <1472053824.14381.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Julien Goodwin <julieng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35448 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753456AbcHXPyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:54:24 -0400
Received: by mail-oi0-f48.google.com with SMTP id 4so28452313oih.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:54:24 -0700 (PDT)
In-Reply-To: <1472053824.14381.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 11:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> TCP MD5 mismatches do increment sk_drops counter in all states but
> SYN_RECV.
>
> This is very unlikely to happen in the real world, but worth adding
> to help diagnostics.
>
> We increase the parent (listener) sk_drops.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
