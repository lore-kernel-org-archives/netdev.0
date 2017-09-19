From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: no need to free qdisc in RCU
 callback
Date: Tue, 19 Sep 2017 14:26:04 -0700
Message-ID: <1505856364.29839.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170919201542.14890-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35226 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISV0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:26:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id j16so480046pga.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 14:26:06 -0700 (PDT)
In-Reply-To: <20170919201542.14890-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 13:15 -0700, Cong Wang wrote:
> gen estimator has been rewritten in commit 1c0d32fde5bd
> ("net_sched: gen_estimator: complete rewrite of rate estimators"),
> the caller no longer needs to wait for a grace period. So this
> patch gets rid of it.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
