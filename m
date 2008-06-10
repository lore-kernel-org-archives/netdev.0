From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPSEC]: pfkey should ignore events when no listeners
Date: Tue, 10 Jun 2008 14:25:44 -0700 (PDT)
Message-ID: <20080610.142544.166544762.davem@davemloft.net>
References: <1212844990.4615.68.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754961AbYFJVZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 17:25:44 -0400
In-Reply-To: <1212844990.4615.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sat, 07 Jun 2008 09:23:10 -0400

> [IPSEC]: pfkey should ignore events when no listeners
> 
> When pfkey has no km listeners, it still does a lot of work
> before finding out there aint nobody out there.
> If a tree falls in a forest and no one is around to hear it, does it make
> a sound? In this case it makes a lot of noise:
> With this short-circuit adding 10s of thousands of SAs using
> netlink improves performance by ~10%.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks Jamal.
