From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: conntrack_helper needs to include rculist.h
Date: Wed, 21 May 2008 14:45:50 -0700 (PDT)
Message-ID: <20080521.144550.151762863.davem@davemloft.net>
References: <20080521142139.f0bc5698.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759361AbYEUVpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 17:45:54 -0400
In-Reply-To: <20080521142139.f0bc5698.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 21 May 2008 14:21:39 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> nf_conntrack_helper users rcu hlist functions so it needs to #include
> rculist.h.
> 
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: implicit declaration of function 'hlist_for_each_entry_rcu'
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: 'hnode' undeclared (first use in this function)
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: (Each undeclared identifier is reported only once
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: for each function it appears in.)
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: expected ';' before '{' token
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:50: warning: unused variable 'mask'
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:74: error: 'hnode' undeclared (first use in this function)
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:74: error: expected ';' before '{' token
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:117: error: implicit declaration of function 'hlist_add_head_rcu'
> linux-next-20080521/net/netfilter/nf_conntrack_helper.c:133: error: implicit declaration of function 'hlist_del_rcu'
> filter/nf_conntrack_helper.o] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

This needs to go in via whatever tree adds the linux/rculist.h header file,
which isn't net-next-2.6 as far as I can tell. :-)

