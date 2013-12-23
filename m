From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] batman-adv: free nf_bridge member on locally
 delivered skb
Date: Sun, 22 Dec 2013 19:16:22 -0500 (EST)
Message-ID: <20131222.191622.118900475665948342.davem@davemloft.net>
References: <1387412132-889-2-git-send-email-antonio@meshcoding.com>
	<20131222.185027.572777902017063381.davem@davemloft.net>
	<52B77F9E.8040201@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3LWAQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 19:16:24 -0500
In-Reply-To: <52B77F9E.8040201@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon, 23 Dec 2013 01:11:10 +0100

> Do you think it is safe to use nf_reset() directly?

If you do not know, you probably should not be making these
changes at all :-)

There is zero reason for your protocol layer to have an ad-hoc private
SKB netfilter state reset function that touches internals in this way.

At least with the generic helpers, we know the side effects and the
function is well known to other developers.
