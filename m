From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Introduce support to lazy initialize mostly static keys
Date: Fri, 27 Sep 2013 01:30:05 +0200
Message-ID: <20130926233005.GA15766@order.stressinduktion.org>
References: <1380236199-3726-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
	fw@strlen.de, ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53983 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab3IZXaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 19:30:07 -0400
Content-Disposition: inline
In-Reply-To: <1380236199-3726-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 01:16:57AM +0200, Hannes Frederic Sowa wrote:
> This series implements support for delaying the initialization of secret
> keys, e.g. used for hashing, for as long as possible. This functionality
> is implemented by a new macro, net_get_random_bytes.
> 
> I already used it to protect the socket hashes, the syncookie secret
> (most important) and the tcp_fastopen secrets.
> 
> This series depends on a patch from Eric Dumazet (already in patchworks):
> "net: net_secret should not depend on TCP"

Oh, sorry. My tunnel was not working. Mails hit a strange fallback. Will
resend shortly.
