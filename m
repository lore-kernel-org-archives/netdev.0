From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 4/4] net: moxa: continue loop on skb allocation
 failure
Date: Mon, 25 Aug 2014 17:26:15 -0700 (PDT)
Message-ID: <20140825.172615.1598002278628891621.davem@davemloft.net>
References: <1408976560-15694-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com
To: jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933658AbaHZA0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:26:16 -0400
In-Reply-To: <1408976560-15694-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Mon, 25 Aug 2014 16:22:40 +0200

> If netdev_alloc_skb_ip_align() fails, subsequent code will
> try to dereference an invalid pointer.
> 
> Continue to next descriptor on error.
> 
> While we're at it,
> 
> 1. eliminate the chance of an endless loop, replace the main
>    loop with while(rx < budget)
> 
> 2. use napi_complete() and remove the explicit napi_gro_flush()
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied.
