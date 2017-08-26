From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Fix may be used uninitialized warning in
 rt6_check
Date: Fri, 25 Aug 2017 17:08:05 -0700 (PDT)
Message-ID: <20170825.170805.189607088439783878.davem@davemloft.net>
References: <20170825070542.GV31224@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiwan@google.com, edumazet@google.com, kafai@fb.com,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755413AbdHZAIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 20:08:06 -0400
In-Reply-To: <20170825070542.GV31224@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Aug 2017 09:05:42 +0200

> rt_cookie might be used uninitialized, fix this by
> initializing it.
> 
> Fixes: c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
