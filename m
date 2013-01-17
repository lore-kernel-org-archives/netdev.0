From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Don't update the pmtu on mtu locked routes
Date: Thu, 17 Jan 2013 03:40:41 -0500 (EST)
Message-ID: <20130117.034041.168603549839573898.davem@davemloft.net>
References: <20130117065500.GG18940@secunet.com>
	<20130117065810.GH18940@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, timo.teras@iki.fi, luky-37@hotmail.com,
	pupilla@libero.it, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932142Ab3AQIkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 03:40:43 -0500
In-Reply-To: <20130117065810.GH18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 17 Jan 2013 07:58:10 +0100

> Routes with locked mtu should not use learned pmtu informations,
> so do not update the pmtu on these routes.
> 
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
