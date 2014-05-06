From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/24] net, diet: Support simpler routing table
Date: Mon, 05 May 2014 23:21:05 -0400 (EDT)
Message-ID: <20140505.232105.633722669086565626.davem@davemloft.net>
References: <1399328773-6531-23-git-send-email-andi@firstfloor.org>
	<20140505.230259.1803147080660592366.davem@davemloft.net>
	<20140506030833.GL2382@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com,
	robert.olsson@its.uu.se
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506030833.GL2382@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 6 May 2014 05:08:33 +0200

> FWIW it seems to me the trie code is very stable, there doesn't
> seem to be any big changes in a long time.

But it was BUGGY AS HELL in the corner cases because it wasn't
the default while it sat next to fib_hash.

It only got totally fixed when it was the ONLY option.

That's exactly my point, parts of it never got tested and were never
verified because debugging resources for it was split with another
implementation.
