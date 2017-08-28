From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 3/3] net/sched: Change act_api and act_xxx
 modules to use IDR
Date: Mon, 28 Aug 2017 17:56:49 -0400
Message-ID: <c8135522-b3e1-0442-ee3f-e29365afae24@mojatatu.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-4-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, davem@davemloft.net,
        mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38337 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdH1V4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:56:51 -0400
Received: by mail-io0-f193.google.com with SMTP id m40so1578340ioi.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:56:51 -0700 (PDT)
In-Reply-To: <1503902477-39829-4-git-send-email-chrism@mellanox.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 02:41 AM, Chris Mi wrote:
> Typically, each TC filter has its own action. All the actions of the
> same type are saved in its hash table. But the hash buckets are too
> small that it degrades to a list. And the performance is greatly
> affected. For example, it takes about 0m11.914s to insert 64K rules.
> If we convert the hash table to IDR, it only takes about 0m1.500s.
> The improvement is huge.
> 
> But please note that the test result is based on previous patch that
> cls_flower uses IDR.
> 
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
