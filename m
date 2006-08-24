From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/44] [XFRM] STATE: Add a hook to obtain local/remote
 outbound address.
Date: Wed, 23 Aug 2006 18:10:39 -0700 (PDT)
Message-ID: <20060823.181039.102123128.davem@davemloft.net>
References: <1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40078
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751279AbWHXBKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:10:37 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:13 +0900

> Outbound transformation replaces both source and destination address with
> state's end-point addresses at the same time when IPsec tunnel mode.
> It is also required to change them for Mobile IPv6 route optimization, but we
> should care about the following differences:
>  - changing result is not end-point but care-of address
>  - either source or destination is replaced for each state
> This hook is a common platform to change outbound address.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
