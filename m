From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] ipv6: Export nd_tbl to allow modules to support
 IPv6
Date: Thu, 6 Sep 2012 04:51:02 -0400
Message-ID: <20120906085102.GA14711@canuck.infradead.org>
References: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
 <20120905.130636.2295422323329670307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:56188 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab2IFIvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:51:06 -0400
Content-Disposition: inline
In-Reply-To: <20120905.130636.2295422323329670307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 01:06:36PM -0400, David Miller wrote:
> So if one of our goals is to move towards a situation where all neigh
> accesses are refcount'less, having those external users makes that
> nearly impossible.
> 
> Instead, I'd rather see patches that mark arp_tbl as being exported
> only for internal usage inside of the tree, so that we can reach that
> goal.
> 
> I'm not applying this, sorry.

Fair enough

Does that mean you dismiss neighbour lookups by external users in
general in order to get rid of the refcnt?

Assuming that lookups would still be ok, would an ipv6 version of
__ipv4_neigh_lookup() be an acceptable API for external users?
(Yes there is __ipv6_neigh_lookup() already but unlike the ipv4 version
it takes the table as first argument)
