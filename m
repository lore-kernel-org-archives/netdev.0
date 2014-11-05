From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Wed, 05 Nov 2014 12:16:22 -0500 (EST)
Message-ID: <20141105.121622.1937064439841390520.davem@davemloft.net>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
	<20141104.164113.2265592775058059992.davem@davemloft.net>
	<1415181185.11486.65.camel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, wei.liu2@citrix.com,
	malcolm.crossley@citrix.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbaKERQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 12:16:24 -0500
In-Reply-To: <1415181185.11486.65.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 5 Nov 2014 09:53:05 +0000

> I'd like to see the commit message expanded to explain why this isn't
> introducing a (security) bug by not pulling enough stuff into the header
> (IOW the conclusion of the discussion).

Just because a fundamental aspect of how we handle packets isn't clear
to some people, doesn't mean that every commit that depends upon that
invariant has to explain it in the commit message. :-)
