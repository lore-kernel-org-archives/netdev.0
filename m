From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 15:38:22 -0500 (EST)
Message-ID: <20130228.153822.333101811485615011.davem@davemloft.net>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758725Ab3B1UiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:38:23 -0500
In-Reply-To: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Thu, 28 Feb 2013 18:16:54 +0100

> Do not include the frame check sequence when adding the skb to
> netif_receive_skb(). This causes problems when this interface was
> bridged to a wifi ap and a big package should be forwarded from this
> Ethernet driver through a bride to the wifi client.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
