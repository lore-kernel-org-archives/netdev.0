From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fib_trie: Use tnode_get_child_rcu() and
 node_parent_rcu() in lookups
Date: Mon, 20 Jul 2009 07:41:31 -0700 (PDT)
Message-ID: <20090720.074131.240024560.davem@davemloft.net>
References: <20090705173208.GB19477@ami.dom.local>
	<20090705213232.GG8943@linux.vnet.ibm.com>
	<20090714212032.GB7952@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org, robert@robur.slu.se
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018AbZGTOlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:41:25 -0400
In-Reply-To: <20090714212032.GB7952@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 14 Jul 2009 23:20:32 +0200

> 
> While looking for other fib_trie problems reported by Pawel Staszewski
> I noticed there are a few uses of tnode_get_child() and node_parent()
> in lookups instead of their rcu versions.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
