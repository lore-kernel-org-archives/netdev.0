From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/2] Account for duplicate ACKs with invalid SACK-blocks
Date: Wed, 21 Aug 2013 20:32:01 -0700 (PDT)
Message-ID: <20130821.203201.369023440348094508.davem@davemloft.net>
References: <1376935800.4226.71.camel@edumazet-glaptop>
	<1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	kernel@linuxace.com, bugfood-ml@fatooh.org,
	benjamin.hesmans@uclouvain.be
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab3HVDcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:32:03 -0400
In-Reply-To: <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Mon, 19 Aug 2013 21:29:26 +0200

> There exist sequence-number rewriting middleboxes, who do not modify the 
> sequence-number in the SACK-blocks.

These are bugs that the vendor's should fix, not something we should
cater to at all.

I'm not applying patches like these, and I've rejected similar
workarounds in the past 18 years, so this position is strong and
consistent.

Sorry.
