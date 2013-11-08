From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 20:25:30 -0800
Message-ID: <1383884730.9412.175.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <1383861288.9412.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108035949.GA14325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45322 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3KHEZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:25:32 -0500
Received: by mail-pb0-f47.google.com with SMTP id rq13so1572700pbb.20
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 20:25:31 -0800 (PST)
In-Reply-To: <20131108035949.GA14325@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 11:59 +0800, Herbert Xu wrote:

> However, I still have one reason for preferring my patch, it'll
> be easier to prodce TSO packets with it.  Let me see if I can
> fix up the arbitrary frag boundary issue without making it too
> ugly.

Sure !
