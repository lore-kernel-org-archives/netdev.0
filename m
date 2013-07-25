From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix comment above build_skb()
Date: Wed, 24 Jul 2013 17:59:31 -0700 (PDT)
Message-ID: <20130724.175931.2162372173516934293.davem@davemloft.net>
References: <1374607359-20024-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab3GYA7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:59:32 -0400
In-Reply-To: <1374607359-20024-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Tue, 23 Jul 2013 20:22:39 +0100

> build_skb() specifies that the data parameter must come from a kmalloc'd
> area, this is only true if frag_size equals 0, because then build_skb()
> will use kzsize(data) to figure out the actual data size. Update the
> comment to reflect that special condition.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
