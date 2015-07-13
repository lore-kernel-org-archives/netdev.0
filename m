From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 16:25:44 +0800
Message-ID: <20150713082544.GA9176@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
 <20150713072352.GA8485@gondor.apana.org.au>
 <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150713081040.GB8971@gondor.apana.org.au>
 <1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38328 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbGMIZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:25:49 -0400
Content-Disposition: inline
In-Reply-To: <1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 10:22:34AM +0200, Eric Dumazet wrote:
>
> It should worry, in case multiple threads are using MSG_PEEK on same udp
> socket ;)

That should be fine because we already hold a spinlock on the
queue.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
