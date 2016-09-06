From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 6 Sep 2016 08:03:33 -0400
Message-ID: <66a91fd3-9d87-9e34-57f1-b44804760a65@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
 <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
 <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
 <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
 <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
 <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
 <1472560518.14381.291.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36420 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753949AbcIFMDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:03:36 -0400
Received: by mail-oi0-f67.google.com with SMTP id u131so5081929oif.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:03:36 -0700 (PDT)
In-Reply-To: <1472560518.14381.291.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-30 08:35 AM, Eric Dumazet wrote:

> synchronize_rcu() might bee to expensive if you plan to change actions
> hundred of times per second.
>
> You could instead add a 'struct rcu_head rcu;'  field in struct
> tcf_skbmod_params  (but make sure this is not exported to user space)
>
> Then :
>
>         if (ovr)
>                  spin_unlock_bh(&d->tcf_lock);
>          kfree_rcu(p_old, rcu);
>

Ok, working on this variant. Will post today or tommorow.

cheers,
jamal
