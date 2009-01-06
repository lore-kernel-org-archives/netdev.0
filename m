From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] can: omit unneeded skb_clone() calls
Date: Tue, 06 Jan 2009 11:08:01 -0800 (PST)
Message-ID: <20090106.110801.170679549.davem@davemloft.net>
References: <4963300E.6010605@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbZAFTH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 14:07:59 -0500
In-Reply-To: <4963300E.6010605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 06 Jan 2009 11:18:54 +0100

> The AF_CAN core delivered always cloned sk_buffs to the AF_CAN
> protocols, although this was _only_ needed by the can-raw protocol.
> With this (additionally documented) change, the AF_CAN core calls the
> callback functions of the registered AF_CAN protocols with the original
> (uncloned) sk_buff pointer and let's the can-raw protocol do the
> skb_clone() itself which omits all unneeded skb_clone() calls for other
> AF_CAN protocols.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>

Applied.
