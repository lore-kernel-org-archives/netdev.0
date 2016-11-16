From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: remove napi_hash_del() call
Date: Wed, 16 Nov 2016 17:05:07 -0500 (EST)
Message-ID: <20161116.170507.2213967213404379563.davem@davemloft.net>
References: <1479304907.8455.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ecree@solarflare.com,
        bkenward@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752278AbcKPWFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:05:09 -0500
In-Reply-To: <1479304907.8455.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 06:01:47 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() after netif_napi_del() is pointless.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
