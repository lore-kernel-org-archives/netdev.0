From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: Speed up CAN frame receiption by
 using ml_priv
Date: Sun, 03 Jan 2010 21:31:29 -0800 (PST)
Message-ID: <20100103.213129.188413356.davem@davemloft.net>
References: <4B34ECB3.4010607@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751770Ab0ADFbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:31:25 -0500
In-Reply-To: <4B34ECB3.4010607@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 25 Dec 2009 17:47:47 +0100

> Hi Urs,
> 
> this patch removes the hlist that contains the CAN receiver filter lists.
> It uses the 'midlayer private' pointer ml_priv and links the filters directly
> to the CAN netdevice, which allows to omit the walk through the complete CAN
> devices hlist for each received CAN frame.
> 
> This patch is tested and does not remove any locking.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied to net-next-2.6
