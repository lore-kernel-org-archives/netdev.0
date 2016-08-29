From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 06:38:14 -0400
Message-ID: <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:38626 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756457AbcH2KiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 06:38:18 -0400
Received: by mail-it0-f41.google.com with SMTP id g62so89626535ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 03:38:18 -0700 (PDT)
In-Reply-To: <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-28 12:07 PM, Eric Dumazet wrote:

> Adding an action with a spinlock held in fast path in 2016 is
> a way to tell people : It is a toy, do not use it for real.
>
> Sorry guys. Friends do not let friends do that anymore.

Generally agree.
Cong says he is working on generic patches. Let me see if i can
try something. Trickery with RCU is not one of my virtues -
so i may get it wrong but hope you can comment.

cheers,
jamal
