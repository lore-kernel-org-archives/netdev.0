From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Fri, 23 Sep 2016 06:42:51 -0700
Message-ID: <1474638171.28155.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160922223411.GA17222@localhost.localdomain>
         <1474586490.28155.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160923124517.GB17222@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34515 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030236AbcIWNmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 09:42:53 -0400
Received: by mail-pa0-f65.google.com with SMTP id i5so1972733pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 06:42:53 -0700 (PDT)
In-Reply-To: <20160923124517.GB17222@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-23 at 09:45 -0300, Marcelo Ricardo Leitner wrote:

> Aye. In that case, what about using tail instead of end?


What do you mean exactly ?

>  Because
> accounting for something that we have to tweak the limits to accept is
> like adding a constant to both sides of the equation.
> But perhaps that would cut out too much of the fat which could be used
> later by the stack.

Are you facing a particular problem with current code ?

I am working to reduce the SACK at their source (the receiver), instead
of trying to filter them when they had to travel all the way back to TCP
sender.
