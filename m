From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dsa: fix skb->pkt_type when mac address of slave
 interface differs
Date: Mon, 10 Nov 2008 21:52:52 -0800 (PST)
Message-ID: <20081110.215252.169940838.davem@davemloft.net>
References: <20081109232255.GD32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751423AbYKKFwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:52:53 -0500
In-Reply-To: <20081109232255.GD32552@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 10 Nov 2008 00:22:55 +0100

> When a dsa slave interface has a mac address that differs from that
> of the master interface, eth_type_trans() won't explicitly set
> skb->pkt_type back to PACKET_HOST -- we need to do this ourselves
> before calling eth_type_trans().
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks Lennert.
