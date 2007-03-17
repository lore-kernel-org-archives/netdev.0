From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [net-2.6.22] IrDA: IrLAP raw mode
Date: Fri, 16 Mar 2007 20:34:51 -0700 (PDT)
Message-ID: <20070316.203451.102575913.davem@davemloft.net>
References: <20070317015729.GA3429@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	netdev@axxeo.de
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933963AbXCQDey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 23:34:54 -0400
In-Reply-To: <20070317015729.GA3429@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Sat, 17 Mar 2007 03:57:29 +0200

> This patch allows us to bypass the IrDA stack down to the IrLAP level.
> Sending and receiving frames is done through a character device.
> This is useful for e.g. doing real IrDA sniffing, testing external IrDA
> stacks and for Lirc (once I will add the framing disabling switch).
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

I understand the idea, but I fail to see any reason this should not be
done with sockets.

Everywhere else we provide this kind of functionality it is either
with netlink (nf_queue etc.) or raw sockets of some kind
(AF_INET/SOCK_RAW, AF_PACKET, etc.)

Therefore IRDA should really provide this facility in some similar
manner.  Besides, character device backdoors for networking are
just ugly :)

