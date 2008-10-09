From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] udp: complete port availability checking
Date: Thu, 09 Oct 2008 14:51:34 -0700 (PDT)
Message-ID: <20081009.145134.216972380.davem@davemloft.net>
References: <48ED34C4.3080203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757100AbYJIVv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:51:58 -0400
In-Reply-To: <48ED34C4.3080203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 09 Oct 2008 00:31:32 +0200

> While looking at UDP port randomization, I noticed it
> was litle bit pessimistic, not looking at type of sockets
> (IPV6/IPV4) and not looking at bound addresses if any.
> 
> We should perform same tests than when binding to a
> specific port.
> 
> This permits a cleanup of udp_lib_get_port()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
