From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] [L2TP] Fix lockup introduced by recent
 changes
Date: Tue, 18 Sep 2007 14:51:06 -0700 (PDT)
Message-ID: <20070918.145106.91759702.davem@davemloft.net>
References: <200709182144.l8ILiXrx008249@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	mostrows@speakeasy.net, paulus@samba.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752527AbXIRVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 17:51:12 -0400
In-Reply-To: <200709182144.l8ILiXrx008249@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Tue, 18 Sep 2007 22:44:33 +0100

> [L2TP] Fix double skb free problem introduced by recent changes 
> 
> This patch is to be applied on top of Herbert's recent patch set:
> "[PPP 3/3] L2TP: Fix skb handling in pppol2tp_xmit"
> 
> It fixes a double kfree_skb() issue introduced by that patch. Also
> return 0 on error, allowing PPP to requeue the skb.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Thanks James.  I've applied this to net-2.6

Herbert, please take a quick look, thanks.
