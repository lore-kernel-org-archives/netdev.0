From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sched: don't use GFP_KERNEL under spin lock
Date: Tue, 05 Sep 2017 14:49:29 -0700 (PDT)
Message-ID: <20170905.144929.1991448009465623628.davem@davemloft.net>
References: <20170905153123.13209-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753350AbdIEVtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:49:31 -0400
In-Reply-To: <20170905153123.13209-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue,  5 Sep 2017 08:31:23 -0700

> The new TC IDR code uses GFP_KERNEL under spin lock.  Which leads
> to:
 ...
> Try to preallocate the memory with idr_prealloc(GFP_KERNEL)
> (as suggested by Eric Dumazet), and change the allocation 
> flags under spin lock.
> 
> Fixes: 65a206c01e8e ("net/sched: Change act_api and act_xxx modules to use IDR")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks.
