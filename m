From: David Miller <davem@davemloft.net>
Subject: Re: [5/4] [NET]: Verify gso_type too in gso_segment
Date: Mon, 03 Jul 2006 19:38:49 -0700 (PDT)
Message-ID: <20060703.193849.21931552.davem@davemloft.net>
References: <20060630054702.GC30149@gondor.apana.org.au>
	<20060630061350.GA3660@gondor.apana.org.au>
	<20060630064134.GA20428@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, Ananda.Raju@neterion.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53456
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751261AbWGDCid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:38:33 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060630064134.GA20428@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jun 2006 16:41:34 +1000

> On Fri, Jun 30, 2006 at 04:13:50PM +1000, herbert wrote:
> > 
> > [NET]: Verify gso_type too in gso_segment
> 
> Here is a better version that ensures at least one of TCPV4 and TCPV6
> is set in tcp_tso_segment.
> 
> [NET]: Verify gso_type too in gso_segment
> 
> We don't want nasty Xen guests to pass a TCPv6 packet in with gso_type set
> to TCPv4 or even UDP (or a packet that's both TCP and UDP).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
