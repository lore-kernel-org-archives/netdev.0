From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix use after free of skb
Date: Tue, 17 Nov 2015 14:40:01 -0500 (EST)
Message-ID: <20151117.144001.631233956285820166.davem@davemloft.net>
References: <fc05eb243454762cf3c2d1ebf2266215d61b23e2.1447704740.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbbKQTkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:40:05 -0500
In-Reply-To: <fc05eb243454762cf3c2d1ebf2266215d61b23e2.1447704740.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 16 Nov 2015 22:44:53 +0100

> ipvlan_handle_frame is a rx_handler, and when it returns a value other
> than RX_HANDLER_CONSUMED (here, NET_RX_DROP aka RX_HANDLER_ANOTHER),
> __netif_receive_skb_core expects that the skb still exists and will
> process it further, but we just freed it.
> 
> Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
