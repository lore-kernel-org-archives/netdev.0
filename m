From: David Miller <davem@davemloft.net>
Subject: Re: netif_needs_gso behavior
Date: Wed, 16 Apr 2008 18:09:46 -0700 (PDT)
Message-ID: <20080416.180946.242234659.davem@davemloft.net>
References: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
	<20080416.013810.214799502.davem@davemloft.net>
	<BAY121-W6E46148E896AA4607937CB6EA0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762030AbYDQBJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 21:09:45 -0400
In-Reply-To: <BAY121-W6E46148E896AA4607937CB6EA0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya B <bkostya@hotmail.com>
Date: Wed, 16 Apr 2008 14:02:56 +0000

> Not always, see udp4_hwcsum_outgoing() In the case when socket queue
> contains several packets, the csum is reset.

USO won't cause this case to occur, I think.
