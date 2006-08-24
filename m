From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/44] [IPV6] MIP6: Add receiving mobility header
 functions through raw socket.
Date: Wed, 23 Aug 2006 20:36:08 -0700 (PDT)
Message-ID: <20060823.203608.12919874.davem@davemloft.net>
References: <11563453674137-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671944-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671187-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39621
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030250AbWHXDgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:36:05 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453671187-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:33 +0900

> Like ICMPv6, mobility header is handled through raw socket.
> In inbound case, check only whether ICMPv6 error should be sent as a reply
> or not by kernel.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> This patch was also written by: Antti Tuominen <anttit@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

> +			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH checksum failed [%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x > %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x]\n",

Let us try to avoid such long lines in the future.

Thanks a lot.
