From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: rename __ipv6_addr_jhash()
Date: Fri, 01 Aug 2014 08:46:15 +0200
Message-ID: <1406875575.3178.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406756298.3178.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140731.215646.951740411089334213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:62798 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaHAGqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 02:46:20 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so3784247wgh.27
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 23:46:19 -0700 (PDT)
In-Reply-To: <20140731.215646.951740411089334213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-31 at 21:56 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Jul 2014 23:38:18 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Remove '__' prefix, it has no purpose.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Actually, I think it does.
> 
> If you look at where this came from, it's commit:
> 
> commit b50026b5ac8fe2932e6af0c54b21da0913c4c1c7
> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date:   Sat Oct 19 21:48:52 2013 +0200
> 
>     ipv6: split inet6_ehashfn to hash functions per compilation unit
> 
> and in that change Hannes uses the convention that __foo() functions
> take an initval argument for the hash computation where as foo()
> functions do not.
> 
> I'm not applying this, sorry :)

Well, there is no ipv6_addr_jhash() anymore.

Should we rename jhash() to __jhash() then ????

This seems pretty odd and useless.
