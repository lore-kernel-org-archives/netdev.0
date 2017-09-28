From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate bpf filter
 handles
Date: Thu, 28 Sep 2017 09:44:04 -0700 (PDT)
Message-ID: <20170928.094404.755168038668150777.davem@davemloft.net>
References: <20170925171351.4956-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, chrism@mellanox.com,
        jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751580AbdI1QoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:44:05 -0400
In-Reply-To: <20170925171351.4956-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 25 Sep 2017 10:13:49 -0700

> Instead of calling cls_bpf_get() in a loop to find
> a unused handle, just switch to idr API to allocate
> new handles.
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Chris Mi <chrism@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
