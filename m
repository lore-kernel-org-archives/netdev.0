From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next-2.6] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Tue, 29 Jun 2010 23:15:31 -0700 (PDT)
Message-ID: <20100629.231531.84378371.davem@davemloft.net>
References: <20100625082447.GK5570@secunet.com>
	<20100628.231812.35040625.davem@davemloft.net>
	<1277861216.28819.36.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	chase.douglas@canonical.com, nordmark@mech.kth.se
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752330Ab0F3GPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:15:18 -0400
In-Reply-To: <1277861216.28819.36.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 30 Jun 2010 02:26:56 +0100

> This avoids scheduling in atomic context and also means that IRQs
> will only be deferred for relatively short periods of time.
> 
> Previously discussed in:
> http://article.gmane.org/gmane.linux.network/155024
> 
> Reported-by: Arne Nordmark <nordmark@mech.kth.se>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
