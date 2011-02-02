From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] gro: reset skb_iif on reuse
Date: Wed, 02 Feb 2011 14:53:44 -0800 (PST)
Message-ID: <20110202.145344.59664804.davem@davemloft.net>
References: <1296682047-15885-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754474Ab1BBWxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 17:53:09 -0500
In-Reply-To: <1296682047-15885-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: andy@greyhouse.net
Date: Wed,  2 Feb 2011 16:27:27 -0500

> Like Herbert's change from a few days ago:
> 
> 66c46d741e2e60f0e8b625b80edb0ab820c46d7a gro: Reset dev pointer on reuse
> 
> this may not be necessary at this point, but we should still clean up
> the skb->skb_iif.  If not we may end up with an invalid valid for
> skb->skb_iif when the skb is reused and the check is done in
> __netif_receive_skb.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks Andy.
