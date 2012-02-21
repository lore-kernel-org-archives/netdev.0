From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 17:02:10 -0500 (EST)
Message-ID: <20120221.170210.1476576306533944488.davem@davemloft.net>
References: <1329860896.18384.61.camel@edumazet-laptop>
	<20120221.165013.133683072829070307.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F96E22@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab2BUWCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:02:14 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F96E22@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Tue, 21 Feb 2012 21:56:14 +0000

> In rtnl_fill_ifinfo the code there uses hlist_for_each_entry_rcu()
> so I think that's why it got carried over here.  I can remove it.

It does so because rtnl_fill_ifinfo() runs within an rcu_read_lock()
sequence.

I fixed up the calcit case when I applied your patch, so we're good
now.
