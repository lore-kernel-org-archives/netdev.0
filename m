From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: properly handle failure case of
 tcf_exts_init()
Date: Mon, 22 Aug 2016 17:02:45 -0700 (PDT)
Message-ID: <20160822.170245.1689979128529376324.davem@davemloft.net>
References: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757316AbcHWADK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 20:03:10 -0400
In-Reply-To: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 19 Aug 2016 12:36:54 -0700

> After commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array")
> we do dynamic allocation in tcf_exts_init(), therefore we need
> to handle the ENOMEM case properly.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
