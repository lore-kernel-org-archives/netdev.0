From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 14:17:52 +0900 (JST)
Message-ID: <20061018.141752.92593935.yoshfuji@linux-ipv6.org>
References: <4415A4C1.1030906@cosmosbay.com>
	<452EA214.7080905@cosmosbay.com>
	<4535B6B7.4070107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:12814 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751377AbWJRFPR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 01:15:17 -0400
To: dada1@cosmosbay.com
In-Reply-To: <4535B6B7.4070107@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4535B6B7.4070107@cosmosbay.com> (at Wed, 18 Oct 2006 07:08:07 +0200), Eric Dumazet <dada1@cosmosbay.com> says:

>  		
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  		struct {
>  			struct in6_addr		daddr;
>  			struct in6_addr		saddr;

#ifdef CONFIG_IPV6_ROUTE_FWMARK

>  			__u32			fwmark;

#endif

>  			__u32			flowlabel;
>  		} ip6_u;
> +#endif
>  
>  		struct {
>  			__le16			daddr;

--yoshfuji
