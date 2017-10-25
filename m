From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Wed, 25 Oct 2017 10:43:53 +0900 (KST)
Message-ID: <20171025.104353.1317026584880877750.davem@davemloft.net>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        jhs@mojatatu.com, john.fastabend@gmail.com, chrism@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751871AbdJYBn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:43:57 -0400
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Oct 2017 15:02:49 -0700

> Recently, the RCU callbacks used in TC filters and TC actions keep
> drawing my attention, they introduce at least 4 race condition bugs:

Like Eric, I think doing a full RCU sync on every delete is too big
a pill to swallow.  This is a major control plane performance
regression.

Please find another reasonable way to fix this.

Thank you.
