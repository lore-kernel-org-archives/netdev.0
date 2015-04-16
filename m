From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 09:33:35 +0100
Message-ID: <20150416083335.GE32170@casper.infradead.org>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <20150415135739.GA5534@gondor.apana.org.au>
 <552E86A6.9000101@6wind.com>
 <20150416010326.GA10864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Morris <jmorris@namei.org>,
	linux-security-module@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41020 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603AbbDPIdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 04:33:37 -0400
Content-Disposition: inline
In-Reply-To: <20150416010326.GA10864@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/15 at 09:03am, Herbert Xu wrote:
> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> harmonize cleanup done on skb on rx path") broke anyone trying to
> use netfilter marking across IPv4 tunnels.  While most of the
> fields that are cleared by skb_scrub_packet don't matter, the
> netfilter mark must be preserved.
> 
> This patch rearranges skb_scrub_packet to preserve the mark field.
> 
> Fixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx path")
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>

We should also add a flag to veth which expclitly allows to preserve
the mark into the namespace.
