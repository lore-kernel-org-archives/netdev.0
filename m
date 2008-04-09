From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: xfrm_user: fix selector family initialization
Date: Wed, 09 Apr 2008 15:09:31 -0700 (PDT)
Message-ID: <20080409.150931.93235087.davem@davemloft.net>
References: <47F4EB73.1040705@trash.net>
	<47FBC2AF.7050508@trash.net>
	<47FCE30F.8060400@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, netdev@vger.kernel.org, kazunori@miyazawa.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756261AbYDIWJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 18:09:31 -0400
In-Reply-To: <47FCE30F.8060400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 09 Apr 2008 17:38:55 +0200

>     [XFRM]: xfrm_user: fix selector family initialization
>     
>     Commit df9dcb45 ([IPSEC]: Fix inter address family IPsec tunnel handling)
>     broke openswan by removing the selector initialization for tunnel mode
>     in case it is uninitialized.
>     
>     This patch restores the initialization, fixing openswan, but probably
>     breaking inter-family tunnels again (unknown since the patch author
>     disappeared). The correct thing for inter-family tunnels is probably
>     to simply initialize the selector family explicitly.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I've applied this to net-2.6, thanks Patrick.

Once we resolve how to get inter-family working without
breaking existing setups, we can put better logic back
in here.  But for now the regression is more important.
