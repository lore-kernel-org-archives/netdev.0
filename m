From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] af_packet: when sending ethernet frames, parse
 header for skb->protocol
Date: Fri, 02 Aug 2013 14:58:52 -0700 (PDT)
Message-ID: <20130802.145852.194407462370278490.davem@davemloft.net>
References: <20130801.181208.804928209108880255.davem@davemloft.net>
	<1375436261-6746-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab3HBV6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:58:53 -0400
In-Reply-To: <1375436261-6746-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri,  2 Aug 2013 11:37:39 +0200

> This may be necessary when the SKB is passed to other layers on the go,
> which check the protocol field on their own. An example is a VLAN packet
> sent out using AF_PACKET on a bridge interface. The bridging code checks
> the SKB size, accounting for any VLAN header only if the protocol field
> is set accordingly.
> 
> Note that eth_type_trans() sets skb->dev to the passed argument, so this
> can be skipped in packet_snd() for ethernet frames, as well.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.
