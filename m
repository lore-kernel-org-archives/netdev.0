From: Eric Dumazet <edumazet@google.com>
Subject: Re: net-next: WARNING: CPU: 0 PID: 1544 at net/ipv4/tcp_input.c:889
Date: Mon, 16 Oct 2017 18:32:29 -0700
Message-ID: <CANn89iJjzB=aq6kNheT++=Q3iwqyj_J2hkhX3SrYGisG1QPbZA@mail.gmail.com>
References: <CANaxB-ymK1yfoK2312JZQH5h2=+50YBfO9oEnE1MJ=n=S_461Q@mail.gmail.com>
 <CANaxB-z=3y+_Eihq-NGRr7YtnyBBNtRo2r4WgKVgTzcJMwTzvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@gmail.com>, Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:52122 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754411AbdJQBca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 21:32:30 -0400
Received: by mail-ua0-f171.google.com with SMTP id 47so100004uas.8
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 18:32:30 -0700 (PDT)
In-Reply-To: <CANaxB-z=3y+_Eihq-NGRr7YtnyBBNtRo2r4WgKVgTzcJMwTzvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 4:11 PM, Andrei Vagin <avagin@gmail.com> wrote:
> Hi Eric,
>
> Could you take a look at this warning? It may be related with your
> recent patches. First time we saw this warning 7 days ago
> (net-next/master) and now we see it regularly.
>
> I printed tp->fackets_out and state->reord  before the warnings and
> here are values for them:
> tp->fackets_out = -1 state->reord = 4
>
> In my case, this warning is triggered for connections which have been
> restored by CRIU.
>
> Let me know if you need any other information. I can reproduce this
> bugs for an hour.
>
> Thanks,
> Andrei

Hi Andrei

We are aware of these recurring issues and Yuchung and other Googlers
decided it was time to remove FACK.

Stay tuned.
