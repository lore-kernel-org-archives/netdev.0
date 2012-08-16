From: David Miller <davem@davemloft.net>
Subject: Re: AF_PACKET + PACKET_FANOUT: tx packet delivered back in rx
Date: Thu, 16 Aug 2012 14:53:22 -0700 (PDT)
Message-ID: <20120816.145322.1154793898136345258.davem@davemloft.net>
References: <1342081817.394175102@f168.mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miquels@drinkel.ow.org
To: a1k@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2HPVxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 17:53:23 -0400
In-Reply-To: <1342081817.394175102@f168.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aleksandr Kotov <a1k@mail.ru>
Date: Thu, 12 Jul 2012 12:30:17 +0400

> I have a problem using AF_PACKET socket with PACKET_RX_RING, PACKET_TX_RING and PACKET_FANOUT options enabled.
> I am seeing my TX packets get back to the same socket in RX ring. Socket is created and gets bind with ETH_P_ALL protocol type. The problem is in the fanout_add function 
> which sets af_packet_priv to "match" variable, but not sk one describing socket and in dev_queue_xmit_nit skb get bounced back to the socket despite the comment left in the function.

Eric Leblong is posting fixes for this problem recently:

http://patchwork.ozlabs.org/patch/178044/
