From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/44] [XFRM] STATE: Support non-fragment outbound
 transformation headers.
Date: Wed, 23 Aug 2006 18:12:08 -0700 (PDT)
Message-ID: <20060823.181208.118950483.davem@davemloft.net>
References: <11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41358
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965315AbWHXBMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:12:06 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:14 +0900

> For originated outbound IPv6 packets which will fragment, ip6_append_data()
> should know length of extension headers before sending them and
> the length is carried by dst_entry.
> IPv6 IPsec headers fragment then transformation was
> designed to place all headers after fragment header.
> OTOH Mobile IPv6 extension headers do not fragment then
> it is a good idea to make dst_entry have non-fragment length to tell it
> to ip6_append_data().
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thank you.
