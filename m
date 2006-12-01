From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][5/7] inter address family ipsec tunnel
Date: Thu, 30 Nov 2006 16:49:03 -0800 (PST)
Message-ID: <20061130.164903.26534926.davem@davemloft.net>
References: <20061124143852.e899dbaf.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:234
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031656AbWLAAtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:49:01 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061124143852.e899dbaf.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 24 Nov 2006 14:38:52 +0900

> +static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
> +{
> +	if (INET_ECN_is_ce(ipv6_get_dsfield(skb->nh.ipv6h)))
> +			IP_ECN_set_ce(skb->h.ipiph);
> +}
> +

Please fix this extra tab indentation :-)

Thank you.

