From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 6421] kernel 2.6.10-2.6.16 on alpha:
 arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1)
 triggered
Date: Sun, 04 Jun 2006 21:48:49 -0700 (PDT)
Message-ID: <20060604.214849.07641306.davem@davemloft.net>
References: <20060603095442.GA373@gondor.apana.org.au>
	<20060603.195123.77471511.yoshfuji@linux-ipv6.org>
	<20060603110711.GA1754@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58787
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932401AbWFEEsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 00:48:52 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060603110711.GA1754@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 3 Jun 2006 21:07:11 +1000

> On Sat, Jun 03, 2006 at 07:51:23PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > I think that people will start thinking why we cannot
> > skb_pull(skb, len) if skb_headlen(skb) == len; some comment needed...
> 
> Good idea.  Here is a better one.
> 
> [TCP]: Avoid skb_pull if possible when trimming head

Applied, thanks a lot Herbert.
