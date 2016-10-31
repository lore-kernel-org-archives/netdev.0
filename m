From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: set SK_MEM_QUANTUM to 4096
Date: Mon, 31 Oct 2016 12:08:48 -0700
Message-ID: <1477940928.7065.313.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADVnQym2dWf8R7Gvx2c03nuiWFLHKrEZM8zOUbF6JFesSRuiCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36259 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944785AbcJaTIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:08:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id n85so9424183pfi.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 12:08:50 -0700 (PDT)
In-Reply-To: <CADVnQym2dWf8R7Gvx2c03nuiWFLHKrEZM8zOUbF6JFesSRuiCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-31 at 15:01 -0400, Neal Cardwell wrote:
> On Mon, Oct 31, 2016 at 2:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Systems with large pages (64KB pages for example) do not always have
> > huge quantity of memory.
> >
> > A big SK_MEM_QUANTUM value leads to fewer interactions with the
> > global counters (like tcp_memory_allocated) but might trigger
> > memory pressure much faster, thus suboptimal TCP performance
> > since windows are lowered to ridiculous values.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> 
>  Acked-by: Neal Cardwell <ncardwell@google.com>
> 
> Thanks, Eric!


Please disregard this patch, I need to change sk_prot_mem_limits() as
well, since tcp_mem[] and udp_mem[] are given in page units.
