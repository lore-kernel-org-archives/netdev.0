From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: use dev_kfree_skb() instead of
 dev_kfree_skb_irq()
Date: Thu, 11 Jun 2009 02:50:55 -0700 (PDT)
Message-ID: <20090611.025055.94547802.davem@davemloft.net>
References: <4A2F7519.8010403@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mjt@tls.msk.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762076AbZFKJux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:50:53 -0400
In-Reply-To: <4A2F7519.8010403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Jun 2009 10:55:53 +0200

> rtl8169_tx_interrupt() is used from NAPI context, it can
> directly free skbs. dev_kfree_skb_irq() is a leftover from
> pre-NAPI times of this driver.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
