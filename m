From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 23:07:28 -0800
Message-ID: <1383808048.9412.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106042858.GA15745@gondor.apana.org.au>
	 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106080425.GA17556@gondor.apana.org.au>
	 <20131106081638.GA17665@gondor.apana.org.au>
	 <20131106131252.GA20680@gondor.apana.org.au>
	 <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107003658.GA27976@gondor.apana.org.au>
	 <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107014724.GA28946@gondor.apana.org.au>
	 <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107055633.GA28986@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com,
	Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:64348 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab3KGHHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:07:30 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr4so176770pbb.25
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 23:07:29 -0800 (PST)
In-Reply-To: <20131107055633.GA28986@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 07:56 +0200, Michael S. Tsirkin wrote:

> I considered doing this but won't this mean packets can get reordered?
> In practice we need to maintain ordering of RX frames within
> a given flow, correct?

Sorry, I was referring to two pools of frags, instead of a single one.

One pool of frags of (1500 + hdr) bytes
One pool of frags of 4096 bytes

But its still one logical queue.
