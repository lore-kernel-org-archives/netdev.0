From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Fri, 25 Jun 2010 13:01:56 +1000
Message-ID: <20100625030156.GB26269@gondor.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjk-0006P2-6r@gondolin.me.apana.org.au> <20100624182123.45264dfe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58579 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284Ab0FYDCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 23:02:06 -0400
Content-Disposition: inline
In-Reply-To: <20100624182123.45264dfe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 06:21:23PM -0700, Andrew Morton wrote:
>
> I just removed the rtnl_unlock() - I couldn't see much in there which
> needed rtnl_locking..

Yes that's the correct fix.  I forgot to remove it from the
recursive setup path after moving the RTNL lock out.  Sorry!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
