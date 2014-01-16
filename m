From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/2] flowcache: Make flow cache name space
 aware
Date: Thu, 16 Jan 2014 11:50:40 -0800 (PST)
Message-ID: <20140116.115040.2172960718523933707.davem@davemloft.net>
References: <1389771254-8738-1-git-send-email-fan.du@windriver.com>
	<1389771254-8738-2-git-send-email-fan.du@windriver.com>
	<20140116101946.GM31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbaAPTul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:50:41 -0500
In-Reply-To: <20140116101946.GM31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 16 Jan 2014 11:19:46 +0100

> So I would not mind to move this into IPsec, but I want to see an ack
> from David before I take this into ipsec-next.

No objections from me.

And longer term I don't even think the flow cache makes sense as the
most appropriate data structure for fast IPSEC lookups either.

Anything that requires GC has fundamental issues.
