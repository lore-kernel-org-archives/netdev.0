From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: use vmalloc_node() for percpu scratches
Date: Mon, 21 Oct 2013 16:48:25 +0200
Message-ID: <20131021144825.GA1509@secunet.com>
References: <20131017095502.GD7660@secunet.com>
 <20131017130740.D8741E8A5E@unicorn.suse.cz>
 <20131018092512.GA31491@secunet.com>
 <1382093656.3284.14.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38456 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab3JUOs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 10:48:28 -0400
Content-Disposition: inline
In-Reply-To: <1382093656.3284.14.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 03:54:16AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> scratches are per cpu, we can use vmalloc_node() for proper
> NUMA affinity.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to ipsec-next, thanks a lot Eric!
