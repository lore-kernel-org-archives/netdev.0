From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/1] geneve: add rtnl changelink support
Date: Mon, 24 Jul 2017 13:51:38 -0700 (PDT)
Message-ID: <20170724.135138.1759454911934870459.davem@davemloft.net>
References: <1500615860-7081-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756003AbdGXUvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:51:39 -0400
In-Reply-To: <1500615860-7081-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Thu, 20 Jul 2017 22:44:20 -0700

> This patch adds changelink rtnl operation support for geneve devices
> and the code changes involve:
> 
>   - added geneve_quiesce() which quiesces the geneve device data path
>     for both TX and RX. This lets us perform the changelink operation
>     atomically w.r.t data path. Also added geneve_unquiesce() to
>     reverse the operation of geneve_quiesce().
> 
>   - refactor geneve_newlink into geneve_nl2info to be used by both
>     geneve_newlink and geneve_changelink
> 
>   - geneve_nl2info takes a changelink boolean argument to isolate
>     changelink checks.
> 
>   - Allow changing only a few attributes (ttl, tos, and remote tunnel
>     endpoint IP address (within the same address family)):
>     - return -EOPNOTSUPP for attributes that cannot be changed for
>       now. Incremental patches can make the non-supported one
>       available in the future if needed.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied.
