From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] IPv6: Fix dst/routing check at transformation.
Date: Thu, 20 Dec 2007 20:41:31 -0800 (PST)
Message-ID: <20071220.204131.89394924.davem@davemloft.net>
References: <11982084391595-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754382AbXLUElc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:41:32 -0500
In-Reply-To: <11982084391595-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 21 Dec 2007 12:40:39 +0900

> IPv6 specific thing is wrongly removed from transformation at net-2.6.25.
> This patch recovers it with current design.
> 
> o Update "path" of xfrm_dst since IPv6 transformation should
>   care about routing changes. It is required by MIPv6 and
>   off-link destined IPsec.
> o Rename nfheader_len which is for non-fragment transformation used by
>   MIPv6 to rt6i_nfheader_len as IPv6 name space.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Applied.
