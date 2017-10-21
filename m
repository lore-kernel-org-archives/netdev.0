From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] ipv6: fixes for RTF_CACHE entries
Date: Sat, 21 Oct 2017 01:40:14 +0100 (WEST)
Message-ID: <20171021.014014.2065653716893988024.davem@davemloft.net>
References: <cover.1508421311.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com, edumazet@google.com,
        hannes@stressinduktion.org, kafai@fb.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752633AbdJUAkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:40:22 -0400
In-Reply-To: <cover.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 19 Oct 2017 16:07:09 +0200

> This series addresses 2 different but related issues with RTF_CACHE introduced
> by the recent refactory.
> 
> patch 1 restore the gc timer for such routes
> patch 2 removes the aged out dst from the fib tree, properly coping with pMTU
> routes
> 
> v1 -> v2:
>  - dropped the  for ip route show cache
>  - avoid touching dst.obsolete when the dst is aged out
> 
> v2 -> v3:
>  - take care of pMTU exceptions

Series applied, thank you.
