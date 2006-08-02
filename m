From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/23] [PATCH] [XFRM]: Expand XFRM_MAX_DEPTH for
 routing header and destination options header.
Date: Tue, 01 Aug 2006 17:16:18 -0700 (PDT)
Message-ID: <20060801.171618.102573695.davem@davemloft.net>
References: <1154165436814-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54670
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750843AbWHBAQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:16:21 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <1154165436814-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:36 +0900

> +#ifdef CONFIG_XFRM_ADVANCED
> +#define XFRM_MAX_DEPTH		6
> +#else
>  #define XFRM_MAX_DEPTH		4
> +#endif

Since I suggest to eliminate XFRM_ADVANCED, we should
do "6" always here if that is what is needed.
