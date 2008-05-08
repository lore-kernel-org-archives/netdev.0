From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [2.6.26] [CAN] Fix can_send() handling on
 dev_queue_xmit() failures
Date: Thu, 08 May 2008 02:50:44 -0700 (PDT)
Message-ID: <20080508.025044.124227730.davem@davemloft.net>
References: <4820B665.6070609@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, nautsch@gmail.com, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754655AbYEHJuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 05:50:51 -0400
In-Reply-To: <4820B665.6070609@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 06 May 2008 21:49:57 +0200

> The tx packet counting and the local loopback of CAN frames should
> only happen in the case that the CAN frame has been enqueued to the
> netdevice tx queue successfully.
> 
> Thanks to Andre Naujoks <nautsch@gmail.com> for reporting this issue.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

Applied, thanks Oliver.

> this patch should go into 2.6.26 and also applies fine on 2.6.25.1.
> 
> IMO this issue is not that 'critical' that it *requires* to become
> part of 2.6.25.2. Please forward the patch to Greg at your own opinion.

I think I'll push it to -stable, thanks.

