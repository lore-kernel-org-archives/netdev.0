From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NET-2.6 1/1] netxen: limit skb frags for non tso packet
Date: Mon, 11 Apr 2011 15:57:36 -0700 (PDT)
Message-ID: <20110411.155736.212673083.davem@davemloft.net>
References: <1302547974-7310-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, stable@kernel.org
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751856Ab1DKW6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:58:11 -0400
In-Reply-To: <1302547974-7310-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 11 Apr 2011 11:52:54 -0700

> Machines are getting deadlock in four node cluster environment.
> All nodes are accessing (find /gfs2 -depth -print|cpio -ocv > /dev/null)
> 200 GB storage on a GFS2 filesystem.
> This result in memory fragmentation and driver receives 18 frags for
> 1448 byte packets.
> For non tso packet, fw drops the tx request, if it has >14 frags.
> 
> Fixing it by pulling extra frags.
> 
> Cc: stable@kernel.org
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

I applied this to net-2.6 earlier today, so:

1) Why are you sending it again?

2) On top of that, why are you sending two copies?

