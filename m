From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipv6: fix handling of blackhole and prohibit routes
Date: Tue, 04 Sep 2012 15:58:36 -0400 (EDT)
Message-ID: <20120904.155836.51164588359279575.davem@davemloft.net>
References: <503F78C8.3070807@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423Ab2IDT6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:58:38 -0400
In-Reply-To: <503F78C8.3070807@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 30 Aug 2012 16:29:28 +0200

> Comments are welcome.

I don't see why we have to create new flags for this.

Handle it like ipv4, where the RTN_* type dictates whether the
route is blackhole, prohibit, or other type of route.
