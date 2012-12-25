From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Tue, 25 Dec 2012 09:27:00 -0800
Message-ID: <1356456420.20133.15020.camel@edumazet-glaptop>
References: <50D9BB19.2080801@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52721 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2LYR1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 12:27:04 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so4540571pad.6
        for <netdev@vger.kernel.org>; Tue, 25 Dec 2012 09:27:03 -0800 (PST)
In-Reply-To: <50D9BB19.2080801@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-25 at 23:41 +0900, YOSHIFUJI Hideaki wrote:

> +	if (!pskb_may_pull(skb, skb->len))
> +		return -EINVAL;
> +

skb_linearize(skb) might be more explicit then.
