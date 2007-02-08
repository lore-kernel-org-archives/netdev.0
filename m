From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [PATCH] spidernet : fix memory leak in spider_net_stop
Date: Thu, 08 Feb 2007 13:15:06 +0900 (JST)
Message-ID: <200702080415.l184FD0I011703@toshiba.co.jp>
References: <45C33DED.8010200@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, linas@austin.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jim@jklewis.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:45148 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030649AbXBHEQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 23:16:04 -0500
In-Reply-To: <45C33DED.8010200@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff-san,

> Jens Osterkamp wrote:
> > We forget to call spider_net_free_rx_chain_contents which does the
> > actual dev_kfree_skb. New skbs are allocated from skbuff_head_cache
> > on each "ifconfig up" letting the cache grow infinitely.
> > 
> > This patch fixes it.
> > 
> > Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
> 
> applied

This fix was applied twice to netdev-2.6.git#upstream.
Because Linas-san's patch has been applied to netdev-2.6.git#upstream.

Best regards,
Kou Ishizaki
