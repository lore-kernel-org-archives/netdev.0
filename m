From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH net-next] sfc: get rid of custom busy polling code
Date: Fri, 3 Feb 2017 09:14:04 +0000
Message-ID: <437a945a-603b-1423-7f45-33ae62aef595@solarflare.com>
References: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:58435 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752145AbdBCJON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:14:13 -0500
In-Reply-To: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/17 01:13, Eric Dumazet wrote:
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

We were talking about doing this just yesterday.
Thanks Eric.

Acked-by: Bert Kenward <bkenward@solarflare.com>
