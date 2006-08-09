From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 18:38:08 -0700 (PDT)
Message-ID: <20060808.183808.74747814.davem@davemloft.net>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	<20060808135721.5af713fb@localhost.localdomain>
	<44D93B60.7030507@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10726
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030405AbWHIBif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:38:35 -0400
To: phillips@google.com
In-Reply-To: <44D93B60.7030507@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 18:33:20 -0700

> Minor rant: the whole skb_alloc familly has degenerated into an unholy
> mess and could use some rethinking.  I believe the current patch gets as
> far as three _'s at the beginning of a function, this shows it is high
> time to reroll the api.

I think it is merely an expression of how dynamic are the operations
that people want to perform on SKBs, and how important it is for
performance to implement COW semantics for the data.
