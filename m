From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: populate skb->l4_rxhash
Date: Mon, 9 Jul 2012 19:15:32 +0300
Message-ID: <1341850532.27035.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1341849744.3265.3219.camel@edumazet-glaptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Willem de Bruijn" <willemb@google.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4991 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218Ab2GIQPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 12:15:48 -0400
In-Reply-To: <1341849744.3265.3219.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 18:02 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> l4_rxhash is set on skb when rxhash is obtained from canonical 4-tuple
> over transport ports/addresses.
> 
> We can set skb->l4_rxhash for all incoming TCP packets on bnx2x for
> free, as cqe status contains a hash type information.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---

This looks very nice :)

Obviously, I have not had a chance to run it in the lab yet, but it
sounds like you already did. So I'm acking it, and will start testing -
if I see anything, I will keep you in the loop...

Thanks Eric!

Acked-by: Eilon Greenstein <eilong@broadcom.com>
