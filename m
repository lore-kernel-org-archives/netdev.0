From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix leak in ipvlan_rcv_frame
Date: Tue, 17 Nov 2015 14:40:21 -0500 (EST)
Message-ID: <20151117.144021.316419372483860209.davem@davemloft.net>
References: <d903709e25790603ab7ba0f43c79171da8485af6.1447705694.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbbKQTkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:40:22 -0500
In-Reply-To: <d903709e25790603ab7ba0f43c79171da8485af6.1447705694.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 16 Nov 2015 22:34:26 +0100

> Pass a **skb to ipvlan_rcv_frame so that if skb_share_check returns a
> new skb, we actually use it during further processing.
> 
> It's safe to ignore the new skb in the ipvlan_xmit_* functions, because
> they call ipvlan_rcv_frame with local == true, so that dev_forward_skb
> is called and always takes ownership of the skb.
> 
> Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
