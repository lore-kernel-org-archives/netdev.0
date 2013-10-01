From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/4] ip_tunnel_core: Change __skb_push back to
 skb_push
Date: Tue, 01 Oct 2013 12:43:29 -0400 (EDT)
Message-ID: <20131001.124329.2206601704189710146.davem@davemloft.net>
References: <20131001093359.GG7660@secunet.com>
	<20131001093551.GI7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab3JAQna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:43:30 -0400
In-Reply-To: <20131001093551.GI7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 1 Oct 2013 11:35:51 +0200

> Git commit 0e6fbc5b ("ip_tunnels: extend iptunnel_xmit()")
> moved the IP header installation to iptunnel_xmit() and
> changed skb_push() to __skb_push(). This makes possible
> bugs hard to track down, so change it back to skb_push().
> 
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
