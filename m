From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:50:13 -0500 (EST)
Message-ID: <20120221.165013.133683072829070307.davem@davemloft.net>
References: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
	<1329860896.18384.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab2BUVuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:50:18 -0500
In-Reply-To: <1329860896.18384.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 22:48:16 +0100

> Thats going to hurt some setups (thousand of devices on a server).

This logic only triggers when the VF attribute is explicitly asked
for.

> Also why are you using _rcu() variant here, we hold rtnl I presume ?

Because that's what I told him to use probably :-)  Indeed, I think
we can use the non-RCU variant in this spot.
