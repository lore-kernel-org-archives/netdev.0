From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ROSE] AX25 packet routing improvement
Date: Mon, 14 Feb 2011 13:35:38 -0800 (PST)
Message-ID: <20110214.133538.28804748.davem@davemloft.net>
References: <4CF78B70.4060907@free.fr>
	<4D596BC9.4030509@upmc.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, f6bvp@free.fr
To: bernard.pidoux@upmc.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39308
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934Ab1BNVfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 16:35:02 -0500
In-Reply-To: <4D596BC9.4030509@upmc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Date: Mon, 14 Feb 2011 18:52:09 +0100

> [PATCH] [ROSE] [AX25] finding routes simplification
> 
> With previous patch, rose_get_neigh() routine
> investigates the full list of neighbor nodes
> until it finds or not an already connected node whether
> it is called locally or through a level 3 transit frame.
> If no routes are opened through an adjacent connected node
> then a classical connect request is attempted.
> 
> Then there is no more reason for an extra loop such
> as the one removed by this patch.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@free.fr>

Also applied to net-next-2.6, thanks!
