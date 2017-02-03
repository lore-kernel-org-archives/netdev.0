From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sfc: get rid of custom busy polling code
Date: Fri, 03 Feb 2017 05:25:45 -0800
Message-ID: <1486128345.21871.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <437a945a-603b-1423-7f45-33ae62aef595@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Bert Kenward <bkenward@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33908 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbdBCNZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:25:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id v184so2015204pgv.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:25:47 -0800 (PST)
In-Reply-To: <437a945a-603b-1423-7f45-33ae62aef595@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 09:14 +0000, Bert Kenward wrote:
> On 03/02/17 01:13, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > In linux-4.5, busy polling was implemented in core
> > NAPI stack, meaning that all custom implementation can
> > be removed from drivers.
> > 
> > Not only we remove lot's of tricky code, we also remove
> > one lock operation in fast path.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Edward Cree <ecree@solarflare.com>
> > Cc: Bert Kenward <bkenward@solarflare.com>
> 
> We were talking about doing this just yesterday.
> Thanks Eric.
> 
> Acked-by: Bert Kenward <bkenward@solarflare.com>

Excellent then, thanks !
