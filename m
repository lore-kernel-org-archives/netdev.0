From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 18:24:53 -0400 (EDT)
Message-ID: <20170424.182453.1488000441860994588.davem@davemloft.net>
References: <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
        <20170424.163033.797679814568299306.davem@davemloft.net>
        <ebfe9e52-f130-3733-9348-aac022a18748@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, tom@herbertland.com, pablo@netfilter.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58526 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978821AbdDXWY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 18:24:58 -0400
In-Reply-To: <ebfe9e52-f130-3733-9348-aac022a18748@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 24 Apr 2017 18:18:42 -0400

> With the posted patch: unknow bits set will result in a kernel
> rejection unless the user space explicitly ask the kernel to ignore
> flags it doesnt understand and just handles what it knows. This
> reduces the amount of work in tc.
...
> [1]
> This is because i worry about making large changes to
> the behavior of user space apps like tc. If I reject I will need to
> change tc to detect this rejection and retry (and I dont think
> extended ACKs in their current shape are ready to provide any
> meaningful detail).

I think we should eat the pain now and use the strict checks
for all new features like this.

I'm sorry if this makes more work for you, but this is really
how we have to proceed moving forward.

Thanks.
