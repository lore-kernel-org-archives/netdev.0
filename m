From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Fri, 23 Dec 2011 04:00:34 -0500 (EST)
Message-ID: <20111223.040034.1806835027241935268.davem@davemloft.net>
References: <20111222102526.GT6348@secunet.com>
	<20111222.135127.1577166695312077920.davem@davemloft.net>
	<20111223084737.GU6348@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab1LWJA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 04:00:59 -0500
In-Reply-To: <20111223084737.GU6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 23 Dec 2011 09:47:37 +0100

> Could you please give a short explaination or point me to where I
> can find this informations?

The routing cache can be easily DoS'd because it fundamentally
has performance which is a product of the characteristics of
the packets we receive, which is controllable by remote entities.

If we get rid of the routing cache, then our lookup performance
will be a product of the contents of the routing table which we
and the administrator have full control over.
