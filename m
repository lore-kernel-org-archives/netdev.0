From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/4] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Tue, 01 Oct 2013 12:43:15 -0400 (EDT)
Message-ID: <20131001.124315.594046983046587429.davem@davemloft.net>
References: <20131001093359.GG7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3JAQnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:43:22 -0400
In-Reply-To: <20131001093359.GG7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 1 Oct 2013 11:33:59 +0200

> We might extend the used aera of a skb beyond the total
> headroom when we install the ipip header. Fix this by
> calling skb_cow_head() unconditionally.
> 
> Bug was introduced with commit c544193214
> ("GRE: Refactor GRE tunneling code.")
> 
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
