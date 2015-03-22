From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 5/10] tipc: Use default rhashtable hashfn
Date: Sun, 22 Mar 2015 11:56:13 +0000
Message-ID: <20150322115613.GF1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarb-0000vg-Ii@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50175 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbCVL4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 07:56:14 -0400
Content-Disposition: inline
In-Reply-To: <E1YZarb-0000vg-Ii@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 07:04pm, Herbert Xu wrote:
> This patch removes the explicit jhash value for the hashfn parameter
> of rhashtable.  The default is now jhash so removing the setting
> makes no difference apart from making one less copy of jhash in
> the kernel.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
