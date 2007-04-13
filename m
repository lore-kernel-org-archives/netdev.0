From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] SNMP: Fix {In,Out}NoRoutes statistics.
Date: Fri, 13 Apr 2007 16:18:21 -0700 (PDT)
Message-ID: <20070413.161821.31759577.davem@davemloft.net>
References: <20070413.173948.133962302.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitch@linux.vnet.ibm.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55334
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030877AbXDMXSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 19:18:20 -0400
In-Reply-To: <20070413.173948.133962302.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 13 Apr 2007 17:39:48 +0900 (JST)

> A packet which is being discarded because of no routes in the
> forwarding path should not be counted as OutNoRoutes but as
> InNoRoutes.
> Additionally, on this occasion, a packet whose destinaion is
> not valid should be counted as InAddrErrors separately.
> 
> Based on patch from Mitsuru Chinen <mitch@linux.vnet.ibm.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you very much.
