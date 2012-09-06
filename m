From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] ipv6: Export nd_tbl to allow modules to support
 IPv6
Date: Thu, 6 Sep 2012 17:06:22 -0400
Message-ID: <20120906210622.GA5204@canuck.infradead.org>
References: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
 <20120905.130636.2295422323329670307.davem@davemloft.net>
 <20120906085102.GA14711@canuck.infradead.org>
 <20120906.134738.425625608685741613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:41719 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933148Ab2IFVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 17:06:23 -0400
Content-Disposition: inline
In-Reply-To: <20120906.134738.425625608685741613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 06, 2012 at 01:47:38PM -0400, David Miller wrote:
> Right now we're in a transition period where ipv4 is mostly refcount'less
> and ipv6 is not.
> 
> This is part of the reason I don't want to expose these things, the
> calling convention and locking requirements are going to be fluid for
> any interface you might propose.
> 
> arp_tbl was exported only for in-tree users, and I therefore say that
> we should only export nd_tbl for in-tree users as well, since that's
> the only way we can audit and update all the referencing callers as
> the semantics radically change.

Thanks for the explanations David. I'll pass this on to the involved
projects. We'll probably try to pick this up again as soon as the new
locking conventions have been put in place and are considered stable.
