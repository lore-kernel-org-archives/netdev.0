From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/44] [XFRM] IPV6: Update outbound state timestamp for
 each sending.
Date: Wed, 23 Aug 2006 18:20:37 -0700 (PDT)
Message-ID: <20060823.182037.133287479.davem@davemloft.net>
References: <1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26024
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965324AbWHXBUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:20:35 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:16 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> With this patch transformation state is updated last used time
> for each sending. Xtime is used for it like other state lifetime
> expiration.
> Mobile IPv6 enabled nodes will want to know traffic status of each
> binding (e.g. judgement to request binding refresh by correspondent node,
> or to keep home/care-of nonce alive by mobile node).
> The last used timestamp is an important hint about it.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Henrik Petander <petander@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied to net-2.6.19
