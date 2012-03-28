From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a potential rcu_read_lock() imbalance in
 rt6_fill_node()
Date: Tue, 27 Mar 2012 21:27:54 -0400 (EDT)
Message-ID: <20120327.212754.389120053569425703.davem@davemloft.net>
References: <1332878032.3547.39.camel@edumazet-glaptop>
	<20120327.182208.806353341087563847.davem@davemloft.net>
	<4F72612A.4020305@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	paulmck@linux.vnet.ibm.com, davej@redhat.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756528Ab2C1B2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 21:28:03 -0400
In-Reply-To: <4F72612A.4020305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 27 Mar 2012 17:54:02 -0700

> I can clean up the ./net/dcb/ code if it will save you some time?

Thanks for offering John, but I can take care of this all myself.
