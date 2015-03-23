From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 6/10] netfilter: Use default rhashtable hashfn
Date: Mon, 23 Mar 2015 22:32:44 +1100
Message-ID: <20150323113243.GA14250@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarc-0000vx-O6@gondolin.me.apana.org.au>
 <20150322115659.GG1185@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52060 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbCWLdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:33:16 -0400
Content-Disposition: inline
In-Reply-To: <20150322115659.GG1185@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 11:56:59AM +0000, Thomas Graf wrote:
> On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > This patch removes the explicit jhash value for the hashfn parameter
> > of rhashtable.  The default is now jhash so removing the setting
> > makes no difference apart from making one less copy of jhash in
> > the kernel.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Looks likes this is not needed given Patrick's work.

OK dropped.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
