From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v7] xps: Improvements in TX queue selection
Date: Wed, 24 Nov 2010 11:45:13 -0800 (PST)
Message-ID: <20101124.114513.35026934.davem@davemloft.net>
References: <alpine.DEB.2.00.1011211501180.14901@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172Ab0KXTor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:44:47 -0500
In-Reply-To: <alpine.DEB.2.00.1011211501180.14901@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 21 Nov 2010 15:17:29 -0800 (PST)

> In dev_pick_tx, don't do work in calculating queue 
> index or setting
> the index in the sock unless the device has more than one queue.  This
> allows the sock to be set only with a queue index of a multi-queue
> device which is desirable if device are stacked like in a tunnel.
> 
> We also allow the mapping of a socket to queue to be changed.  To
> maintain in order packet transmission a flag (ooo_okay) has been
> added to the sk_buff structure.  If a transport layer sets this flag
> on a packet, the transmit queue can be changed for the socket.
> Presumably, the transport would set this if there was no possbility
> of creating OOO packets (for instance, there are no packets in flight
> for the socket).  This patch includes the modification in TCP output
> for setting this flag.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
