From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: do not call napi_hash_del()
Date: Wed, 16 Nov 2016 17:07:02 -0500 (EST)
Message-ID: <20161116.170702.1946497230265430495.davem@davemloft.net>
References: <1479305562.8455.176.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753449AbcKPWHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:07:05 -0500
In-Reply-To: <1479305562.8455.176.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 06:12:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() before netif_napi_del() is dangerous
> if a synchronize_rcu() is not enforced before NAPI struct freeing.
> 
> Lets leave this detail to core networking stack and feel
> more comfortable.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
