From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Fri, 06 Jul 2007 17:43:46 +1000
Message-ID: <1183707826.6005.177.camel@localhost.localdomain>
References: <20070705231615.451797310@linux-foundation.org>
	 <20070705.164308.01771618.davem@davemloft.net>
	 <20070705170051.37ff2ab8@freepuppy.localdomain.hemminger.net>
	 <20070705.171535.105173068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40489 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760042AbXGFHoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 03:44:07 -0400
In-Reply-To: <20070705.171535.105173068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-05 at 17:15 -0700, David Miller wrote:
> Also even with the scatterlist idea, we'd still need to do two
> map calls, one for skb->data and one for the page vector.

We could make skb->shinfo(skb)->frags[0] the first segment and deprecate
skb->data and skb->len.

OK, you can stop hitting me now...
Rusty.


