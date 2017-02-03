From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: get rid of custom busy polling code
Date: Fri, 03 Feb 2017 09:57:40 -0500 (EST)
Message-ID: <20170203.095740.259963875600809782.davem@davemloft.net>
References: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ecree@solarflare.com,
        bkenward@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdBCO5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 09:57:45 -0500
In-Reply-To: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 17:13:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In linux-4.5, busy polling was implemented in core
> NAPI stack, meaning that all custom implementation can
> be removed from drivers.
> 
> Not only we remove lot's of tricky code, we also remove
> one lock operation in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
