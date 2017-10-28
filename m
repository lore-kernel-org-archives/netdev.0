From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] tcp: move 12 sysctls to namespaces
Date: Sat, 28 Oct 2017 19:25:01 +0900 (KST)
Message-ID: <20171028.192501.1857493069489518244.davem@davemloft.net>
References: <20171027144732.23885-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJ1KZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 06:25:05 -0400
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 27 Oct 2017 07:47:20 -0700

> Ideally all TCP sysctls should be per netns.
> This patch series takes care of 12 sysctls.

Series applied, thanks Eric.

> Remains the ones that need discussion :
> 
> sysctl_tcp_mem, sysctl_tcp_rmem, sysctl_tcp_wmem, and sysctl_tcp_max_orphans

Yeah those will be tricky.
