From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [1/2] gro: Only verify TCP checksums for candidates
Date: Thu, 21 Nov 2013 21:55:12 -0800
Message-ID: <1385099712.10637.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5286F018.8060801@gmail.com>
	 <20131116064611.GA12146@gondor.apana.org.au> <528A51B6.2040609@intel.com>
	 <20131121.133501.272071098922555423.davem@davemloft.net>
	 <20131122023013.GA6387@gondor.apana.org.au>
	 <20131122023129.GA6506@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	alexander.duyck@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:64868 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab3KVFzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 00:55:14 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so832298pbc.35
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 21:55:13 -0800 (PST)
In-Reply-To: <20131122023129.GA6506@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-22 at 10:31 +0800, Herbert Xu wrote:
> In some cases we may receive IP packets that are longer than
> their stated lengths.  Such packets are never merged in GRO.
> However, we may end up computing their checksums incorrectly
> and end up allowing packets with a bogus checksum enter our
> stack with the checksum status set as verified.
> 
> Since such packets are rare and not performance-critical, this
> patch simply skips the checksum verification for them.
> 
> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Eric Dumazet <edumazet@google.com>
