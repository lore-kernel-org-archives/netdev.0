From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: PACKET_TX_RING: packet size is too long
Date: Thu, 29 Oct 2009 03:19:17 -0700 (PDT)
Message-ID: <20091029.031917.255459167.davem@davemloft.net>
References: <20091009220546.GB7618@boogie.lpds.sztaki.hu>
	<20091013.005438.32630424.davem@davemloft.net>
	<20091015201028.GA9780@boogie.lpds.sztaki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net
To: gombasg@sztaki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752330AbZJ2KSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:18:54 -0400
In-Reply-To: <20091015201028.GA9780@boogie.lpds.sztaki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabor Gombas <gombasg@sztaki.hu>
Date: Thu, 15 Oct 2009 22:10:29 +0200

> Currently PACKET_TX_RING forces certain amount of every frame to remain
> unused. This probably originates from an early version of the
> PACKET_TX_RING patch that in fact used the extra space when the (since
> removed) CONFIG_PACKET_MMAP_ZERO_COPY option was enabled. The current
> code does not make any use of this extra space.
> 
> This patch removes the extra space reservation and lets userspace make
> use of the full frame size.
> 
> Signed-off-by: Gabor Gombas <gombasg@sztaki.hu>

Applied, thanks!
