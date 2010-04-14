From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fix potential wild pointer when NIC is dying
Date: Tue, 13 Apr 2010 21:23:06 -0700
Message-ID: <1271218986.1555.29.camel@Joe-Laptop.home>
References: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1472 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777Ab0DNEXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 00:23:10 -0400
In-Reply-To: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 20:18 +0800, Changli Gao wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a10a216..fe4a821 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[]
> -static void flush_backlog(void *arg)
> +static int flush_backlog(void *arg)

Why change this to return int?

> +	return 0;

It seems to always return 0.

