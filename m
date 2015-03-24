From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/5 net-next] rhashtable: Disable automatic shrinking by
 default
Date: Tue, 24 Mar 2015 19:28:45 +0000
Message-ID: <20150324192845.GC19251@casper.infradead.org>
References: <cover.1427202823.git.tgraf@suug.ch>
 <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
 <20150324185545.GA15837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37734 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbCXT2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:28:47 -0400
Content-Disposition: inline
In-Reply-To: <20150324185545.GA15837@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/15 at 05:55am, Herbert Xu wrote:
> On Tue, Mar 24, 2015 at 02:18:19PM +0100, Thomas Graf wrote:
> > Using rhashtable_remove_fast() will no longer automatically
> > shrink the table. Users need to opt-in to shrinking by
> > explicitly using rhashtable_remove_and_shrink()
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Note that this patch doesn't completely disable automatic shrinking
> since the worker thread can still trigger it.

Right. I'll send a v2.
