From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC ipsec-next 5/5] esp: Add a software GRO codepath
Date: Wed, 08 Feb 2017 13:19:56 -0500 (EST)
Message-ID: <20170208.131956.1793646962232036920.davem@davemloft.net>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
        <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, ilant@mellanox.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdBHSUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:20:03 -0500
In-Reply-To: <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 7 Feb 2017 10:14:11 +0100

> +static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
> +					 struct sk_buff *skb)
> +{
> +	int err;
> +	__be32 seq;
> +	__be32 spi;
> +	struct xfrm_state *x;
> +	int offset = skb_gro_offset(skb);

Please order local variable declarations from longest to shortest.

> +static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
> +					 struct sk_buff *skb)
> +{
> +	int err;
> +	__be32 seq;
> +	__be32 spi;
> +	struct xfrm_state *x;
> +	int offset = skb_gro_offset(skb);

Likewise.

Thank you.
