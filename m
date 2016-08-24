From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: get rid of SLAB_DESTROY_BY_RCU allocations
Date: Tue, 23 Aug 2016 17:46:30 -0700 (PDT)
Message-ID: <20160823.174630.1025545863233232658.davem@davemloft.net>
References: <1471971471.14381.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56159 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753150AbcHXAyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:54:40 -0400
In-Reply-To: <1471971471.14381.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Aug 2016 09:57:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
> we do not need this special allocation mode anymore, even if it is
> harmless.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
