From: Thomas Graf <tgraf@redhat.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 11:40:10 +0200
Message-ID: <1274348410.23393.13.camel@lsx.localdomain>
References: <4BF4517F.1010206@athenacr.com>
	 <20100519.195533.22536631.davem@davemloft.net>
	 <20100520025741.GA6129@gondor.apana.org.au>
	 <20100519.200522.140743640.davem@davemloft.net>
	 <20100520033446.GA6434@gondor.apana.org.au>
	 <1274332507.2658.31.camel@edumazet-laptop>
	 <20100520052059.GC7443@gondor.apana.org.au>
	 <1274333779.2658.43.camel@edumazet-laptop>
	 <20100520054642.GA7836@gondor.apana.org.au>
	 <20100520065242.GA8719@gondor.apana.org.au>
	 <1274343043.23393.7.camel@lsx.localdomain>
Reply-To: tgraf@redhat.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, bmb@athenacr.com,
	nhorman@tuxdriver.com, nhorman@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab0ETJkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 05:40:35 -0400
In-Reply-To: <1274343043.23393.7.camel@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-20 at 10:10 +0200, Thomas Graf wrote: 
> There is a fundamental problem with this. The process needs to be
> associated with the cgroup before any sockets get created. Sockets
> are often created right after the application starts. This means that
> the only viable option is to start each application in a wrapper which
> assigns itself to the cgroup and then forks the application as its
> child. If a task is associated with a cgroup after it has started it
> may lead to unpredictable outcome because only some of the sockets
> may end up being classified.
> 
> This was the actual reason for the old method.

Disregard this. I didn't read your latest patch correctly.

