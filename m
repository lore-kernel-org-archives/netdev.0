From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 08 Jun 2007 09:12:52 -0400
Message-ID: <1181308372.4063.126.camel@localhost>
References: <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
	 <1181256848.4071.57.camel@localhost>
	 <20070607.160035.00774597.davem@davemloft.net>
	 <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
	 <1181266536.4741.27.camel@localhost>
	 <20070608103925.GA23598@gondor.apana.org.au>
	 <1181302497.4063.37.camel@localhost>
	 <20070608123735.GA24582@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:55860 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968955AbXFHNNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 09:13:13 -0400
Received: by nz-out-0506.google.com with SMTP id n1so725383nzf
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 06:13:12 -0700 (PDT)
In-Reply-To: <20070608123735.GA24582@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 22:37 +1000, Herbert Xu wrote:

> Hmm I wasn't describing how it works now.  I'm talking about how it
> would work if we removed LLTX and replaced the private tx_lock with
> netif_tx_lock.

I got that - it is what tg3 does for example.
To mimick that behavior in LLTX, a driver needs to use the same lock on
both tx and receive. e1000 holds a different lock on tx path from rx
path. Maybe theres something clever i am missing; but it seems to be a
bug on e1000.
The point i was making is that it was strange i never had problems
despite taking away the lock on the tx side and using the rx side
concurently.

cheers,
jamal



