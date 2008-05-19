From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/4] [IPV6] ROUTE: Fix lifetime in netlink.
Date: Mon, 19 May 2008 16:55:20 -0700 (PDT)
Message-ID: <20080519.165520.261460815.davem@davemloft.net>
References: <20080515.181802.13113123.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40613
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754833AbYESXzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 19:55:25 -0400
In-Reply-To: <20080515.181802.13113123.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 15 May 2008 18:18:02 +0900 (JST)

> We could not see appropriate lifetime if the route had been scheduled
> to expired at 0 (in jiffies).  We should check rt6i_flags instead of
> rt6i_expires to determine whether lifetime is valid or not.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
