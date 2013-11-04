From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 22:46:21 -0800
Message-ID: <1383547581.4291.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104042913.GA23021@gondor.apana.org.au>
	 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104052321.GA23252@gondor.apana.org.au>
	 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104062202.GA23719@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63613 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab3KDGqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 01:46:23 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so6344170pdj.11
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 22:46:22 -0800 (PST)
In-Reply-To: <20131104062202.GA23719@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 14:22 +0800, Herbert Xu wrote:

> So what NICs were you using that had this issue?

Its a generic issue, really.

It depends on how many flows are mixed per RX queues.
