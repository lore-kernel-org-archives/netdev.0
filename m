From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Tue, 27 Apr 2010 12:54:28 -0700 (PDT)
Message-ID: <20100427.125428.71578099.davem@davemloft.net>
References: <20100228054012.GA7583@gondor.apana.org.au>
	<E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
	<20100427101311.2f445227@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756756Ab0D0TyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:54:22 -0400
In-Reply-To: <20100427101311.2f445227@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 27 Apr 2010 10:13:11 -0700

> I prefer that the hlist be only accessed through the hlist macro
> objects. Explicit twiddling of links (especially with RCU) exposes
> the code to future bugs.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Yes this by-hand stuff was beyond awful, I'm sorry I didn't catch it
when pulling in these changes initially :-)

Applied, thanks Stephen.
