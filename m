From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 22:08:03 +1000
Message-ID: <20060816120803.GA29664@gondor.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816113950.GA29003@gondor.apana.org.au> <1155729864.5122.95.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, hasso@estpak.ee, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12301 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751127AbWHPMIb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 08:08:31 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155729864.5122.95.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 08:04:24AM -0400, jamal wrote:
> 
> What do you think of the idea of infact rewriting the pid to be that of
> the socket id?

Rewriting it with the netlink socket address? That's fine by me as
long as there is a clear 1-to-1 relationship between the request
and the notification.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
