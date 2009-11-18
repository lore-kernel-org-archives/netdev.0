From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: introduce NETDEV_UNREGISTER_PERNET
Date: Wed, 18 Nov 2009 05:04:24 -0800 (PST)
Message-ID: <20091118.050424.53037982.davem@davemloft.net>
References: <200911170149.35240.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbZKRNEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 08:04:11 -0500
In-Reply-To: <200911170149.35240.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 17 Nov 2009 01:49:35 +0200

> This new event is called once for each unique net namespace in batched
> unregister operations (with the argument set to a random device from
> that namespace) and once per device in non-batched unregister
> operations.
> 
> It allows us to factorize some device unregister work such as clearing the
> routing cache.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied to net-next-2.6
