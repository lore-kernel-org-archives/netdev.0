From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/3] net/sched: Improve getting objects by
 indexes
Date: Wed, 30 Aug 2017 14:39:15 -0700 (PDT)
Message-ID: <20170830.143915.721461254974312457.davem@davemloft.net>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, mawilcox@microsoft.com
To: chrism@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdH3VjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:39:17 -0400
In-Reply-To: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mi <chrism@mellanox.com>
Date: Wed, 30 Aug 2017 02:31:56 -0400

> Using current TC code, it is very slow to insert a lot of rules.
> 
> In order to improve the rules update rate in TC,
> we introduced the following two changes:
>         1) changed cls_flower to use IDR to manage the filters.
>         2) changed all act_xxx modules to use IDR instead of
>            a small hash table
> 
> But IDR has a limitation that it uses int. TC handle uses u32.
> To make sure there is no regression, we add several new IDR APIs
> to support unsigned long.
> 
> v2
> ==
> 
> Addressed Hannes's comment:
> express idr_alloc in terms of idr_alloc_ext and most of the other functions

Series applied, thanks.
