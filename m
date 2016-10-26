From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp/dccp: drop SYN packets if accept queue is full
Date: Wed, 26 Oct 2016 14:39:47 -0400
Message-ID: <CADVnQy=f==Ffk_=xPN7hOHyu5sHqhgi3rUw89rTYn1fxF7HdqQ@mail.gmail.com>
References: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33107 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbcJZSkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:40:19 -0400
Received: by mail-oi0-f49.google.com with SMTP id y2so5106375oie.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 11:40:18 -0700 (PDT)
In-Reply-To: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 12:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Per listen(fd, backlog) rules, there is really no point accepting a SYN,
> sending a SYNACK, and dropping the following ACK packet if accept queue
> is full, because application is not draining accept queue fast enough.
>
> This behavior is fooling TCP clients that believe they established a
> flow, while there is nothing at server side. They might then send about
> 10 MSS (if using IW10) that will be dropped anyway while server is under
> stress.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Great. Thanks, Eric!

neal
