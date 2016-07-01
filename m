From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch
 areas
Date: Fri, 01 Jul 2016 04:03:41 -0400 (EDT)
Message-ID: <20160701.040341.2029216245486805623.davem@davemloft.net>
References: <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	<1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbcGAIEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 04:04:38 -0400
In-Reply-To: <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Jun 2016 18:51:53 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Some arches have virtually mapped kernel stacks, or will soon have.
> 
> tcp_md5_hash_header() uses an automatic variable to copy tcp header
> before mangling th->check and calling crypto function, which might
> be problematic on such arches.
> 
> David says that using percpu storage is also problematic on non SMP
> builds.
> 
> Just use kmalloc() to allocate scratch areas.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andy Lutomirski <luto@amacapital.net>

Applied, thanks.
