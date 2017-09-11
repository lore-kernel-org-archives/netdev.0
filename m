From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: fix pointer check in gen_handle
Date: Mon, 11 Sep 2017 14:35:02 -0700 (PDT)
Message-ID: <20170911.143502.998165379504365686.davem@davemloft.net>
References: <1505072930-13049-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdIKVfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:35:03 -0400
In-Reply-To: <1505072930-13049-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Sun, 10 Sep 2017 15:48:50 -0400

> Fixes sparse warning about pointer in gen_handle:
> net/sched/cls_rsvp.h:392:40: warning: Using plain integer as NULL pointer
> 
> Fixes: 8113c095672f6 ("net_sched: use void pointer for filter handle")
> Signed-off-by: Josh Hunt <johunt@akamai.com>

Applied.
