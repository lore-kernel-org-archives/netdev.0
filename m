From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: hold the transport before using it in
 sctp_hash_cmp
Date: Fri, 09 Sep 2016 19:17:46 -0700 (PDT)
Message-ID: <20160909.191746.1850636311022712919.davem@davemloft.net>
References: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752806AbcIJCRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 22:17:50 -0400
In-Reply-To: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  8 Sep 2016 17:49:04 +0800

> Now sctp uses the transport without holding it in sctp_hash_cmp,
> it can cause a use-after-free panic. As after it get transport from
> hashtable, another CPU may free it, then the members it accesses
> may be unavailable memory.
> 
> This patch is to use sctp_transport_hold, in which it checks the
> refcnt first, holds it if it's not 0.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Please add more detail to the commit message and add a proper
"Fixes: " tag right before your signoff.

Thanks.
