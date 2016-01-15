From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: update skb->csum when CE mark is propagated
Date: Fri, 15 Jan 2016 15:07:56 -0500 (EST)
Message-ID: <20160115.150756.1662802308203397449.davem@davemloft.net>
References: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	tom@herbertland.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbcAOUH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 15:07:58 -0500
In-Reply-To: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Jan 2016 04:56:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When a tunnel decapsulates the outer header, it has to comply
> with RFC 6080 and eventually propagate CE mark into inner header.
> 
> It turns out IP6_ECN_set_ce() does not correctly update skb->csum
> for CHECKSUM_COMPLETE packets, triggering infamous "hw csum failure"
> messages and stack traces.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
