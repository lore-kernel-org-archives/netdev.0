From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root.
 Now=15 size=11 bits
Date: Mon, 20 Jul 2009 07:41:13 -0700 (PDT)
Message-ID: <20090720.074113.89003675.davem@davemloft.net>
References: <20090705173208.GB19477@ami.dom.local>
	<20090705213232.GG8943@linux.vnet.ibm.com>
	<20090714183308.GB3090@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org, robert@robur.slu.se
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300AbZGTOlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:41:07 -0400
In-Reply-To: <20090714183308.GB3090@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 14 Jul 2009 20:33:08 +0200

> ipv4: Use synchronize_rcu() during trie_rebalance()
> 
> During trie_rebalance() we free memory after resizing with call_rcu(),
> but large updates, especially with PREEMPT_NONE configs, can cause
> memory stresses, so this patch calls synchronize_rcu() in
> tnode_free_flush() after each sync_pages to guarantee such freeing
> (especially before resizing the root node).
> 
> The value of sync_pages = 128 is based on Pawel Staszewski's tests as
> the lowest which doesn't hinder updating times. (For testing purposes
> there was a sysfs module parameter to change it on demand, but it's
> removed until we're sure it could be really useful.)
> 
> The patch is based on suggestions by: Paul E. McKenney
> <paulmck@linux.vnet.ibm.com>
> 
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
