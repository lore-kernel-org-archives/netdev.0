From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add
 netdev_txq_bql_{enqueue,complete}_prefetchw() helpers
Date: Wed, 08 Oct 2014 16:09:07 -0400 (EDT)
Message-ID: <20141008.160907.363332341502233858.davem@davemloft.net>
References: <CA+r1ZhiU6uzE-CQcTJoH2JxrS06H+5Paaofz+3Ugzon02mxD8Q@mail.gmail.com>
	<1412779746.11091.176.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412781567.11091.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim.epost@gmail.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, amirv@mellanox.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657AbaJHUJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 16:09:10 -0400
In-Reply-To: <1412781567.11091.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Oct 2014 08:19:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Add two helpers so that drivers do not have to care of BQL being
> available or not.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Fixes: 29d40c903247 ("net/mlx4_en: Use prefetch in tx path")

Applied.
