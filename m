From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 20:24:43 -0800
Message-ID: <1383884683.9412.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108032208.GA14056@gondor.apana.org.au>
	 <1383883594.9412.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108041016.GB14325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:56370 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458Ab3KHEYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:24:45 -0500
Received: by mail-pb0-f42.google.com with SMTP id jt11so1602327pbb.29
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 20:24:45 -0800 (PST)
In-Reply-To: <20131108041016.GB14325@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 12:10 +0800, Herbert Xu wrote:

> Well you still don't seem to be getting this: If you need it for
> the host then you will need it even more for virt because the
> network stack there is much longer.
> 
> So having it only available to the host without also giving it
> to virt makes *zero* sense.

I am fine with this, but how can we know the packet is going to be
delivered to virt instead of forwarded to ethernet ?

Do we want the equivalent of 'IP early demux', done at GRO layer ? ;)
