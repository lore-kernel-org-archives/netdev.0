From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: rename __ipv6_addr_jhash()
Date: Thu, 31 Jul 2014 21:56:46 -0700 (PDT)
Message-ID: <20140731.215646.951740411089334213.davem@davemloft.net>
References: <1406756298.3178.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbaHAE4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 00:56:47 -0400
In-Reply-To: <1406756298.3178.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Jul 2014 23:38:18 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove '__' prefix, it has no purpose.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Actually, I think it does.

If you look at where this came from, it's commit:

commit b50026b5ac8fe2932e6af0c54b21da0913c4c1c7
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Sat Oct 19 21:48:52 2013 +0200

    ipv6: split inet6_ehashfn to hash functions per compilation unit

and in that change Hannes uses the convention that __foo() functions
take an initval argument for the hash computation where as foo()
functions do not.

I'm not applying this, sorry :)
