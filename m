From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [IPSEC]: Store IPv6 nh pointer in mac_header on
 output
Date: Tue, 09 Oct 2007 13:26:11 -0700 (PDT)
Message-ID: <20071009.132611.115640703.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCG-0005Lp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752966AbXJIU0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:26:11 -0400
In-Reply-To: <E1IfGCG-0005Lp-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:32 +0800

> [IPSEC]: Store IPv6 nh pointer in mac_header on output
> 
> Current the x->mode->output functions store the IPv6 nh pointer in the
> skb network header.  This is inconvenient because the network header then
> has to be fixed up before the packet can leave the IPsec stack.  The mac
> header field is unused on output so we can use that to store this instead.
> 
> This patch does that and removes the network header fix-up in xfrm_output.
> 
> It also uses ipv6_hdr where appropriate in the x->type->output functions.
> 
> There is also a minor clean-up in esp4 to make it use the same code as
> esp6 to help any subsequent effort to merge the two.
> 
> Lastly it kills two redundant skb_set_* statements in BEET that were
> simply copied over from transport mode.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
