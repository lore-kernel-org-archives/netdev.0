From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Wed, 27 Apr 2016 15:20:53 -0400 (EDT)
Message-ID: <20160427.152053.2243888701043810040.davem@davemloft.net>
References: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbcD0TU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 15:20:57 -0400
In-Reply-To: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 22 Apr 2016 17:58:02 +0200

> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.
> 
> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
> CC: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> Tom, when I read the comment, I feel I'm misssing something, but what?

Tom, seriously, please look at this.

And with recent changes in net-next the csum attribute size needs to
be specified as well, plus the locator needs to use the 64-bit
alignment sizing helper.
