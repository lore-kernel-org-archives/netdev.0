From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 4/9] e100 driver conversion
Date: Tue, 08 Aug 2006 22:18:03 +0200
Message-ID: <1155068284.23134.23.camel@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	 <20060808193405.1396.14701.sendpatchset@lappy> <44D8F074.8060001@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:1567 "EHLO
	amsfep18-int.chello.nl") by vger.kernel.org with ESMTP
	id S964955AbWHHUSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 16:18:45 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44D8F074.8060001@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 13:13 -0700, Auke Kok wrote:
> Peter Zijlstra wrote:
> > Update the driver to make use of the netdev_alloc_skb() API and the
> > NETIF_F_MEMALLOC feature.
> 
> this should be done in two separate patches. I should take care of the netdev_alloc_skb()
> part too for e100 (which I've already queued internally), also since ixgb still needs it.
> 
> do you have any plans to visit ixgb for this change too?

Well, all drivers are queued, these were just the ones I have hardware
for in running systems (except wireless).

Since this patch-set is essentially a RFC, your patch will likely hit
mainline ere this one, at that point I'll rebase.

For future patches I'll split up in two if people are so inclined.


