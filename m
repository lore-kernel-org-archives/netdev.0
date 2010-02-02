From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: deny filterlist access on non-CAN
 interfaces
Date: Tue, 02 Feb 2010 07:21:47 -0800 (PST)
Message-ID: <20100202.072147.26974083.davem@davemloft.net>
References: <4B5EF37F.7070906@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753413Ab0BBPVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:21:34 -0500
In-Reply-To: <4B5EF37F.7070906@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 26 Jan 2010 14:51:59 +0100

> In commit 20dd3850bcf860561496827b711fa10fecf6e787 "can: Speed up CAN frame
> receiption by using ml_priv" the formerly used hlist of receiver lists for
> each CAN netdevice has been replaced. 
> 
> The hlist content ensured only CAN netdevices to be accessed by the
> can_rx_(un)register() functions which accidently dropped away together with
> the hlist receiver implementation.
> 
> This patch re-introduces the check for CAN netdevices in can_rx_(un)register().
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks Oliver.
