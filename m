From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove support for per driver
 ndo_busy_poll()
Date: Fri, 03 Feb 2017 15:04:55 -0800
Message-ID: <1486163095.21871.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203.171820.956894207079399896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34343 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdBCXE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:04:56 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so2416672pfb.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:04:56 -0800 (PST)
In-Reply-To: <20170203.171820.956894207079399896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 17:18 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Feb 2017 18:43:28 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > We added generic support for busy polling in NAPI layer in linux-4.5
> > 
> > No network driver uses ndo_busy_poll() anymore, we can get rid
> > of the pointer in struct net_device_ops, and its use in sk_busy_loop()
> > 
> > Saves NETIF_F_BUSY_POLL features bit.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Nice ! Thanks !
