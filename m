From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 12:19:59 +0800
Message-ID: <20131030041959.GA3162@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.220253.1263087684709722001.davem@davemloft.net>
 <1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
 <20131030040818.GB2755@gondor.apana.org.au>
 <1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60764 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:20:04 -0400
Content-Disposition: inline
In-Reply-To: <1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:16:17PM -0700, Eric Dumazet wrote:
>
> The thing is this only matters for hosts receiving at line rate on few
> TCP flows.
> 
> A router should not build too big GRO packets, as it adds latencies.
> 
> Really, we had to make TSO packets being auto sized, lets not add the
> syndrome again.
> 
> So I do not really understand David concern about emitting a warning.
> 
> If a machine is used as a router, building GRO packets of 17 MSS is
> absolutely fine.

It's not just routers you know, we use the same code on bridges
as part of virtualisation.  So it absolutely does matter.

In fact this is why I wrote GRO in the first place, to make it
work for virtualisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
