From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: remove clear_sk() method
Date: Wed, 24 Aug 2016 06:35:30 -0700
Message-ID: <1472045730.14381.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
         <20160823.233728.1295346525678892725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34136 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754342AbcHXNfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 09:35:32 -0400
Received: by mail-pf0-f182.google.com with SMTP id p64so7067393pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 06:35:32 -0700 (PDT)
In-Reply-To: <20160823.233728.1295346525678892725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 23:37 -0700, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Tue, 23 Aug 2016 11:39:25 -0700
> 
> > Since IPv6 socket lookups no longer dereference pinet6 pointer
> > and UDP lost SLAB_DESTROY_BY_RCU special rules, we no longer
> > need special clear_sk() methods.
> 
> Series applied, thanks Eric.
> 
> There were some merge conflicts because I applied David Ahern's
> sock diag udp patches first.
> 
> Please double check my work.

Sure, this all looks fine to me, thanks David !
