From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tcp: use tcp_flags in tcp_data_queue()
Date: Sun, 28 Sep 2014 16:38:37 -0400 (EDT)
Message-ID: <20140928.163837.2085219030985059581.davem@davemloft.net>
References: <1411564948.15395.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<ba777860fdfc42d53ecd35bdac5d81ca5a9872eb.1411568111.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaI1Uii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 16:38:38 -0400
In-Reply-To: <ba777860fdfc42d53ecd35bdac5d81ca5a9872eb.1411568111.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Wed, 24 Sep 2014 22:17:02 +0800

> This patch is a cleanup which follows the idea in commit e11ecddf5128 (tcp: use
> TCP_SKB_CB(skb)->tcp_flags in input path),
> and it may reduce register pressure since skb->cb[] access is fast,
> bacause skb is probably in a register.
> 
> v2: remove variable th
> v3: reword the changelog
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Applied, thanks.
