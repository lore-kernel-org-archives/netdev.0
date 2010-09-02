From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Wed, 01 Sep 2010 17:37:36 -0700 (PDT)
Message-ID: <20100901.173736.190380817.davem@davemloft.net>
References: <20100901.143815.215547115.davem@davemloft.net>
	<1283377631.5323.285.camel@localhost>
	<1283378907.5323.287.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182Ab0IBAhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 20:37:20 -0400
In-Reply-To: <1283378907.5323.287.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 01 Sep 2010 23:08:27 +0100

> I think this is safe after all because ethtool and MII ioctls are all
> serialised by the RTNL.

Well since you said that there was a regression that you're unable
to reproduce, I was trying to find a probably cause for it :-)

I think you should work to resolve that report, and resend this
locking patch once that is sorted out.

Thanks.
