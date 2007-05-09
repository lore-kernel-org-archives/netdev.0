From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6]: Do no rely on skb->dst before it is assigned.
Date: Wed, 09 May 2007 14:02:35 -0700 (PDT)
Message-ID: <20070509.140235.23718189.davem@davemloft.net>
References: <20070509.191835.125516836.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758921AbXEIVCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 17:02:35 -0400
In-Reply-To: <20070509.191835.125516836.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 09 May 2007 19:18:35 +0900 (JST)

> Because skb->dst is assigned in ip6_route_input(), it is really
> bad to use it in hop-by-hop option handler(s).
> 
> This fix is also needed for -stable.
> 
> Closes: Bug #8450 (Eric Sesterhenn <snakebyte@gmx.de>)
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
