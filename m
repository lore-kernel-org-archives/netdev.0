From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 4/10] netlink: Use default rhashtable hashfn
Date: Sun, 22 Mar 2015 11:55:43 +0000
Message-ID: <20150322115543.GE1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:50165 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbbCVLzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 07:55:44 -0400
Content-Disposition: inline
In-Reply-To: <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
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
