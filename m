From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC ipsec-next 1/5] xfrm: Add a secpath_set helper.
Date: Wed, 08 Feb 2017 13:18:57 -0500 (EST)
Message-ID: <20170208.131857.813682261784593072.davem@davemloft.net>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
        <1486458851-4920-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, ilant@mellanox.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbdBHSS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:18:59 -0500
In-Reply-To: <1486458851-4920-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 7 Feb 2017 10:14:07 +0100

> +int secpath_set(struct sk_buff *skb)
> +{
> +	struct sec_path *sp;
> +
> +	/* Allocate new secpath or COW existing one. */
> +	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
> +
> +		sp = secpath_dup(skb->sp);

Please remove this empty line.

Thanks.
