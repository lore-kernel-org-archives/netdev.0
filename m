From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/44] [XFRM] STATE: Add a hook to find offset to be
 inserted header in outbound.
Date: Wed, 23 Aug 2006 17:57:52 -0700 (PDT)
Message-ID: <20060823.175752.45743419.davem@davemloft.net>
References: <11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58023
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750749AbWHXA5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:57:50 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:08 +0900

> On current kernel, ip6_find_1stfragopt() is used by IPv6 IPsec to find offset to
> be inserted header in outbound for transport mode. (BTW, no usage may be needed for
> IPv4 case.)
> Mobile IPv6 requires another logic for routing header and destination options
> header respectively. This patch is common platform for the offset and adopts it to
> IPsec.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied to net-2.6.19, thanks a lot.
