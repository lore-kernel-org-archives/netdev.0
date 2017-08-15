From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched/sfq: update hierarchical backlog when drop
 packet
Date: Tue, 15 Aug 2017 07:50:49 -0700
Message-ID: <1502808649.4936.80.camel@edumazet-glaptop3.roam.corp.google.com>
References: <150280422406.717624.15125218636935056461.stgit@buzz>
         <1502806179.4936.76.camel@edumazet-glaptop3.roam.corp.google.com>
         <9d01e66a-5855-ea9a-ff63-c029ceb46c98@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:37286 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdHOOuz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:50:55 -0400
Received: by mail-pg0-f43.google.com with SMTP id y129so6903560pgy.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:50:55 -0700 (PDT)
In-Reply-To: <9d01e66a-5855-ea9a-ff63-c029ceb46c98@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 17:33 +0300, Konstantin Khlebnikov wrote:

> Nope. I'm not sure. But we have something similar in our 4.4 kernel
> for a while.
> 
> Also fq_codel and pfifo_head_drop do something similar tho this.
> 
> Probably this might crash without "[PATCH 1/2] net_sched: call
> qlen_notify only if child qdisc is empty".
> I hadn't tested them separately.

Thanks for the info. I've read this patch and it looks fine indeed :)

Acked-by: Eric Dumazet <edumazet@google.com>
