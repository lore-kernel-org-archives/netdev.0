From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 03:46:27 -0700 (PDT)
Message-ID: <20110621.034627.30677905865798284.davem@davemloft.net>
References: <20110621.025334.547463578193934724.davem@davemloft.net>
	<4E0074CF.8070003@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310Ab1FUKqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 06:46:32 -0400
In-Reply-To: <4E0074CF.8070003@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Victor Julien <victor@inliniac.net>
Date: Tue, 21 Jun 2011 12:39:11 +0200

> The hash based on skb->rxhash, does that result in a "flow" based
> distribution over the listeners? So all packets sharing a tuple
> being sent to the same socket?

Yes, that's exactly right.
