From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: better validation of received ack
 sequences
Date: Thu, 25 May 2017 09:50:51 -0700
Message-ID: <1495731051.6465.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
         <1495578286.6465.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170525.124817.1960721450872387047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: p.fiterau-brostean@science.ru.nl, netdev@vger.kernel.org,
        F.Vaandrager@cs.ru.nl, ncardwell@google.com, ycheng@google.com,
        soheil@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33641 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942744AbdEYQu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:50:58 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so40373675pfe.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:50:58 -0700 (PDT)
In-Reply-To: <20170525.124817.1960721450872387047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-25 at 12:48 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 May 2017 15:24:46 -0700
> 
> > Add a FLAG_NO_CHALLENGE_ACK so that tcp_rcv_state_process()
> > can choose to send a challenge ACK and discard the packet instead
> > of wrongly change socket state.
> 
> Applied, but the tests end up being double-negatives so it might
> have been easier to understand if the flag was a positive rather
> than a negative value.

I thought of this (and was in fact one of the patch I sent for internal
review at Google), but this was changing all tcp_ack() calls instead of
a single one ?

Or maybe I am missing some easier way ?

Thanks
