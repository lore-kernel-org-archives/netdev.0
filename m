From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 27/44] [IPV6] IPSEC: Support sending with Mobile IPv6
 extension headers.
Date: Thu, 24 Aug 2006 05:36:46 +0900 (JST)
Message-ID: <20060824.053646.74121481.yoshfuji@linux-ipv6.org>
References: <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35080 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965188AbWHWUe7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 16:34:59 -0400
To: davem@davemloft.net, nakam@linux-ipv6.org
In-Reply-To: <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> (at Thu, 24 Aug 2006 00:02:28 +0900), YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> says:

> +#ifdef CONFIG_IPV6_MIP6
> +	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
> +		goto out;
> +#else
>  	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
>  		goto free_out;
> +#endif

Oops, I missed this.

This will result in memory leakage...
We will fix it with some clean-ups in the next spin.

--yoshfuji
