From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: fib_hash removal
Date: Thu, 15 Mar 2007 10:15:44 +0100
Message-ID: <20070315091544.GB1671@ff.dom.local>
References: <20070315074046.GA1671@ff.dom.local> <45F8F93F.6010408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, tgr@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:46288 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752691AbXCOJL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 05:11:28 -0400
Content-Disposition: inline
In-Reply-To: <45F8F93F.6010408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 08:43:59AM +0100, Patrick McHardy wrote:
...
> > On 14-03-2007 23:49, Patrick McHardy wrote:
...
> >>BUG: sleeping function called from invalid context at mm/slab.c:3032
> >>in_atomic():1, irqs_disabled():0
...
> Yes, Robert already sent me a patch to remove the bogus preempt_disable,
> but IIRC it was there to make sure changes to the tree don't interfere
> with packet processing, so we might need to do something else. I'll try
> to look into it later today.
> 

BTW: it seems fib_tree wasn't used too much, so probably,
before killing fib_hash, fib_tree should be made Kconfig
default for some time.

Jarek P.
