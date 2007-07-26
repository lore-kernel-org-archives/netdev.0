From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TIPC: fix tipc_link_create error handling
Date: Thu, 26 Jul 2007 00:05:21 -0700 (PDT)
Message-ID: <20070726.000521.88703127.davem@davemloft.net>
References: <20070723183423.GA9380@Chamillionaire.breakpoint.cc>
	<AF1602CB2550CE4381C0C75118A7856B015BE75E@ala-mail02.corp.ad.wrs.com>
	<20070724220256.GC8732@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758115AbXGZHFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:05:22 -0400
In-Reply-To: <20070724220256.GC8732@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Wed, 25 Jul 2007 00:02:56 +0200

> if printbuf allocation or tipc_node_attach_link() fails, invalid
> references to the link are left in the associated node and bearer
> structures.
> Fix by allocating printbuf early and moving timer initialization
> and the addition of the new link to the b_ptr->links list after
> tipc_node_attach_link() succeeded.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Looks good Florian, patch applied, thanks.
