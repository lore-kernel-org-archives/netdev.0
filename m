From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH net-next] sfc-falcon: get rid of custom busy polling code
Date: Fri, 3 Feb 2017 09:15:06 +0000
Message-ID: <542e7a72-c8a3-6a18-e21e-b4d46f379443@solarflare.com>
References: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486088548.21871.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:40537 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752332AbdBCJPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:15:16 -0500
In-Reply-To: <1486088548.21871.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/17 02:22, Eric Dumazet wrote:
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
> Cc: Edward Cree <ecree@solarflare.com>
> Cc: Bert Kenward <bkenward@solarflare.com>

Acked-by: Bert Kenward <bkenward@solarflare.com>
