From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] rhashtable: Fix walker behaviour during rehash
Date: Sat, 14 Mar 2015 00:06:35 +0000
Message-ID: <20150314000635.GI17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWML8-0000B6-62@gondolin.me.apana.org.au>
 <20150313155023.GG17829@casper.infradead.org>
 <20150313234221.GA9020@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60204 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788AbbCNAGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 20:06:37 -0400
Content-Disposition: inline
In-Reply-To: <20150313234221.GA9020@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/15 at 10:42am, Herbert Xu wrote:
> On Fri, Mar 13, 2015 at 03:50:23PM +0000, Thomas Graf wrote:
> >
> > Is there a reason to keeping rhashtable_walk_init() and
> > rhashtable_walk_start() separate? It seems like one always has
> > to call init for each iteration as start does not reset the
> > iterator bits. It would also safe a mutex_lock().
> 
> Yes they are needed for netlink users, e.g., netfilter.  Proc
> users will always init/start while netlink users can init, and
> then just use start/stop to keep their state.

OK, it's for future code. Thanks.
