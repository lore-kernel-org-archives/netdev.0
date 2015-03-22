From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 5/10]
Date: Sun, 22 Mar 2015 18:55:42 +1100
Message-ID: <20150322075542.GA2856@gondor.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
 <E1YZahg-0000iQ-CL@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41620 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbCVHz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:55:56 -0400
Content-Disposition: inline
In-Reply-To: <E1YZahg-0000iQ-CL@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 06:53:48PM +1100, Herbert Xu wrote:
> 
> This patch removes the explicit jhash value for the hashfn parameter
> of rhashtable.  The default is now jhash so removing the setting
> makes no difference apart from making one less copy of jhash in
> the kernel.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Oops, due to an extra blank line in the commit the Subject went
missing.  Resent with the correct subject.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
