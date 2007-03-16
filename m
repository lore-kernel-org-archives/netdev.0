From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_hash removal
Date: Fri, 16 Mar 2007 14:41:04 -0700 (PDT)
Message-ID: <20070316.144104.25475545.davem@davemloft.net>
References: <17914.36807.643615.571195@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgr@suug.ch,
	Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbXCPVlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 17:41:06 -0400
In-Reply-To: <17914.36807.643615.571195@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 16 Mar 2007 13:38:31 +0100

> 
> Hello, Just discussed this Patrick...
> 
> We have two users of trie_leaf_remove, fn_trie_flush and fn_trie_delete 
> both are holding RTNL. So there shouldn't be need for this preempt stuff. 
> This is assumed to a leftover from an older RCU-take.
> 
> > Mhh .. I think I just remembered something - me incorrectly suggesting
> > to add it there while we were talking about this at OLS :) IIRC the
> > idea was to make sure tnode_free (which at that time didn't use
> > call_rcu) wouldn't free memory while still in use in a rcu read-side
> > critical section. It should have been synchronize_rcu of course,
> > but with tnode_free using call_rcu it seems to be completely
> > unnecessary. So I guess we can simply remove it.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks a lot.
