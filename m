From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/44] [XFRM]: Rename secpath_has_tunnel to
 secpath_has_nontransport.
Date: Wed, 23 Aug 2006 18:09:35 -0700 (PDT)
Message-ID: <20060823.180935.95504784.davem@davemloft.net>
References: <11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61322
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751266AbWHXBJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:09:33 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:12 +0900

> On current kernel inbound transformation state is allowed transport and
> disallowed tunnel mode when mismatch is occurred between tempates and states.
> As the result of adding two more modes by Mobile IPv6, this function name
> is misleading. Inbound transformation can allow only transport mode
> when mismatch is occurred between template and secpath.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
