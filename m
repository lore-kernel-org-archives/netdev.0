From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/4] tipc: add net device to skb before UDP
 xmit
Date: Sun, 06 Mar 2016 22:57:56 -0500 (EST)
Message-ID: <20160306.225756.238167641576416273.davem@davemloft.net>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcCGD57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:57:59 -0500
In-Reply-To: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Thu, 3 Mar 2016 14:20:40 +0100

> Prior to this patch enabling a IPv4 UDP bearer caused a null pointer
> dereference in iptunnel_xmit_stats(), when it tried to dereference the
> net device from the skb. To resolve this we now point the skb device
> to the net device resolved from the routing table.
> 
> Fixes: 039f50629b7f (ip_tunnel: Move stats update to iptunnel_xmit())
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@gmail.com>

Applied.
