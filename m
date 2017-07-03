From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/2] skbuff: Function to send an skbuf on a socket
Date: Mon, 03 Jul 2017 06:00:57 -0700 (PDT)
Message-ID: <20170703.060057.586366984268237880.davem@davemloft.net>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
        <1498760825-8516-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752706AbdGCNBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 09:01:05 -0400
In-Reply-To: <1498760825-8516-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 29 Jun 2017 11:27:04 -0700

> +int skb_send_sock(struct sk_buff *skb, struct socket *sock, unsigned int offset)
> +{
> +	unsigned int sent = 0;
> +	unsigned int ret;
> +	unsigned short fragidx;

Please use reverse christmas tree ordering for these local variables.

> +	/* Deal with head data */
> +	while (offset < skb_headlen(skb)) {
> +		size_t len = skb_headlen(skb) - offset;
> +		struct kvec kv;
> +		struct msghdr msg;

Likewise.
