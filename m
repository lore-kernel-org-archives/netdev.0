From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: net_secret should not depend on TCP
Date: Wed, 25 Sep 2013 01:51:47 +0200
Message-ID: <20130924235147.GA9335@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924054532.GA24446@order.stressinduktion.org> <1380028797.3165.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48790 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab3IXXvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 19:51:48 -0400
Content-Disposition: inline
In-Reply-To: <1380028797.3165.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 06:19:57AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> A host might need net_secret[] and never open a single socket. 
> 
> Problem added in commit aebda156a570782
> ("net: defer net_secret[] initialization")
> 
> Based on prior patch from Hannes Frederic Sowa.
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

FWIW, I reviewed that the loop indeed cannot block and gave the patch a
quick test drive. Also, the ipv6_hash_secret is only used by the ehash
functions. So this is a superior patch than mine:

Acked-by: Hannes Frederic Sowa <hannes@strressinduktion.org>

Thanks, Eric!
