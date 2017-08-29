From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] net: frag: print frag_mem_limit value in sockstat
 proc file
Date: Tue, 29 Aug 2017 16:04:01 -0700 (PDT)
Message-ID: <20170829.160401.1682245884573191819.davem@davemloft.net>
References: <1504011934-17308-1-git-send-email-liujian56@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, brouer@redhat.com,
        fw@strlen.de, netdev@vger.kernel.org
To: liujian56@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH2XEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:04:01 -0400
In-Reply-To: <1504011934-17308-1-git-send-email-liujian56@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <liujian56@huawei.com>
Date: Tue, 29 Aug 2017 21:05:34 +0800

> From: liujian <liujian56@huawei.com>
> 
> From 6d7b857d5( net: use lib/percpu_counter API for fragmentation mem
> accounting),
> frag_mem_limit and sum_frag_mem_limit have different value if there are
> multiple NIC RX CPU.
> Print frag_mem_limit value, then we can get more debug info.
> 
> Signed-off-by: liujian <liujian56@huawei.com>

Sorry, I don't think it is justified to change the deprecated procfs
output just for this.

Use tracepoints and other similar facilities to debug situations
like this if you like.
