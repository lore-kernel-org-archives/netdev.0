From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] : add a missing rcu synchronization
Date: Wed, 16 Nov 2016 23:31:06 -0500 (EST)
Message-ID: <20161116.233106.2234599506618839323.davem@davemloft.net>
References: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932333AbcKQEbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 23:31:07 -0500
In-Reply-To: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 06:31:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Add a missing synchronize_net() call to avoid potential use after free,
> since we explicitly call napi_hash_del() to factorize the RCU grace
> period.
> 
> Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Michael Chan <michael.chan@broadcom.com>

Applied.
