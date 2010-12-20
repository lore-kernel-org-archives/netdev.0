From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Sun, 19 Dec 2010 21:50:34 -0800 (PST)
Message-ID: <20101219.215034.59672253.davem@davemloft.net>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, jpirko@redhat.com,
	fenghua.yu@intel.com, junchangwang@gmail.com, xinan.tang@intel.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54426
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750783Ab0LTFuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 00:50:05 -0500
In-Reply-To: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 16 Dec 2010 13:57:25 +0800

> In dev_queue_xmit_nit(), we have to clone skbs as we need to mangle skbs,
> however, we don't need to clone skbs for all the packet_types.
> 
> Except for the first packet_type, we increase skb->users instead of
> skb_clone().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
