From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: remove bogus hardware vlan acceleration flags
 from vlan_features
Date: Thu, 20 Feb 2014 02:16:49 -0500 (EST)
Message-ID: <20140220.021649.1758178843439700559.davem@davemloft.net>
References: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1392726009-8083-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fernando@oss.ntt.co.jp, maxk@qti.qualcomm.com,
	netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaBTHQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 02:16:50 -0500
In-Reply-To: <1392726009-8083-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 18 Feb 2014 21:20:09 +0900

> From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> 
> Even though only the outer vlan tag can be HW accelerated in the transmission
> path, in the TUN/TAP driver vlan_features mirrors hw_features, which happens
> to have the NETIF_F_HW_VLAN_?TAG_TX flags set. Because of this, during packet
> tranmisssion through a stacked vlan device dev_hard_start_xmit, (incorrectly)
> assuming that the vlan device supports hardware vlan acceleration, does not
> add the vlan header to the skb payload and the inner vlan tags are lost
> (vlan_tci contains the outer vlan tag when userspace reads the packet from
> the tap device).
> 
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable.
