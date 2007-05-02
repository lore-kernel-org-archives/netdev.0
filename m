From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER] sip: Fix RTP address NAT
Date: Wed, 02 May 2007 15:19:21 +0200
Message-ID: <46388FD9.1030907@trash.net>
References: <20070502040102.GA28343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35354 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993155AbXEBNUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 09:20:30 -0400
In-Reply-To: <20070502040102.GA28343@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [NETFILTER] sip: Fix RTP address NAT
> 
> I needed to use this recently to talk to a Cisco server.  In my case
> I only did SNAT while the Cisco server used a different address for
> RTP traffic than the one for SIP.  I discovered that nf_nat_sip NATed
> the RTP address to the SIP one which was unnecessary but OK.  However,
> in doing so it did not DNAT the destination address on the RTP traffic
> to the Cisco back to the original RTP address.
> 
> This patch corrects this by noting down the RTP address and using it
> when the expectation fires.


Applied, thanks a lot Herbert. My last attempt at fixing this resulted
in a patch that was too ugly to live :)

