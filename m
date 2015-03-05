From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Extend Proxy ARP design to allow optional
 rules for Wi-Fi
Date: Thu, 05 Mar 2015 14:52:48 -0500 (EST)
Message-ID: <20150305.145248.37517018117219982.davem@davemloft.net>
References: <1425466461-1371-1-git-send-email-jouni@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jouni@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbCETzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 14:55:35 -0500
In-Reply-To: <1425466461-1371-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <jouni@codeaurora.org>
Date: Wed,  4 Mar 2015 12:54:21 +0200

> This extends the design in commit 958501163ddd ("bridge: Add support for
> IEEE 802.11 Proxy ARP") with optional set of rules that are needed to
> meet the IEEE 802.11 and Hotspot 2.0 requirements for ProxyARP. The
> previously added BR_PROXYARP behavior is left as-is and a new
> BR_PROXYARP_WIFI alternative is added so that this behavior can be
> configured from user space when required.
> 
> In addition, this enables proxyarp functionality for unicast ARP
> requests for both BR_PROXYARP and BR_PROXYARP_WIFI since it is possible
> to use unicast as well as broadcast for these frames.
> 
> The key differences in functionality:
> 
> BR_PROXYARP:
> - uses the flag on the bridge port on which the request frame was
>   received to determine whether to reply
> - block bridge port flooding completely on ports that enable proxy ARP
> 
> BR_PROXYARP_WIFI:
> - uses the flag on the bridge port to which the target device of the
>   request belongs
> - block bridge port flooding selectively based on whether the proxyarp
>   functionality replied
> 
> Signed-off-by: Jouni Malinen <jouni@codeaurora.org>

Applied to net-next, thanks.
