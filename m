From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] : add a missing rcu synchronization
Date: Wed, 16 Nov 2016 20:59:11 -0800
Message-ID: <1479358751.8455.237.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161116.233106.2234599506618839323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35175 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbcKQE7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 23:59:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so16555177pga.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 20:59:13 -0800 (PST)
In-Reply-To: <20161116.233106.2234599506618839323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-16 at 23:31 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 16 Nov 2016 06:31:52 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Add a missing synchronize_net() call to avoid potential use after free,
> > since we explicitly call napi_hash_del() to factorize the RCU grace
> > period.
> > 
> > Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Michael Chan <michael.chan@broadcom.com>
> 
> Applied.

Thanks David for the title fix ;)
