From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] net: set SK_MEM_QUANTUM to 4096
Date: Mon, 31 Oct 2016 15:01:14 -0400
Message-ID: <CADVnQym2dWf8R7Gvx2c03nuiWFLHKrEZM8zOUbF6JFesSRuiCw@mail.gmail.com>
References: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33325 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945718AbcJaTBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:01:45 -0400
Received: by mail-oi0-f41.google.com with SMTP id 128so47556594oih.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 12:01:45 -0700 (PDT)
In-Reply-To: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 2:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Systems with large pages (64KB pages for example) do not always have
> huge quantity of memory.
>
> A big SK_MEM_QUANTUM value leads to fewer interactions with the
> global counters (like tcp_memory_allocated) but might trigger
> memory pressure much faster, thus suboptimal TCP performance
> since windows are lowered to ridiculous values.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

 Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
