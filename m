From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] fib_hash removal
Date: Mon, 19 Mar 2007 13:21:19 +0100
Message-ID: <17918.32831.649420.260477@robur.slu.se>
References: <17914.36807.643615.571195@robur.slu.se>
	<20070316154839.GA3626@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, tgr@suug.ch, Jens.Laas@data.slu.se,
	hans.liss@its.uu.se
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:34868 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932334AbXCSMVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 08:21:31 -0400
In-Reply-To: <20070316154839.GA3626@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Paul E. McKenney writes:

 > > We have two users of trie_leaf_remove, fn_trie_flush and fn_trie_delete 
 > > both are holding RTNL. So there shouldn't be need for this preempt stuff. 
 > > This is assumed to a leftover from an older RCU-take.
 > 
 > True enough!  One request -- would it be reasonable to add to
 > trie_leaf_remove()'s comment to state that RTNL must be held
 > by the caller?
 
 Thanks for your review.  Yes but it's implicitly assumed that updater
 side holds RTNL and we have a comment that states we're run by updater. 
 If mention RTNL here we should probably comment other places too. ;)

 Cheers
				       --ro
