From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 21:08:49 -0800
Message-ID: <1383887329.9412.207.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108032359.GA14132@gondor.apana.org.au>
	 <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108042425.GA14577@gondor.apana.org.au>
	 <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108044335.GA14787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51733 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab3KHFIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 00:08:50 -0500
Received: by mail-pd0-f175.google.com with SMTP id g10so1629852pdj.6
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 21:08:50 -0800 (PST)
In-Reply-To: <20131108044335.GA14787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 12:43 +0800, Herbert Xu wrote:

> Easy.  You don't physically segment the packet until it's
> transmitted.  But logically you treat each GRO/GSO packet as if it
> had already been segmented.

OK, please submit some patches, because I must be blind.
