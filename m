From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: fix spurious timestamping callbacks
Date: Tue, 26 Apr 2016 01:14:02 -0400 (EDT)
Message-ID: <20160426.011402.1149307286644324220.davem@davemloft.net>
References: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcDZFOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 01:14:05 -0400
In-Reply-To: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Apr 2016 11:35:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When multiple skb are TX-completed in a row, we might incorrectly keep
> a timestamp of a prior skb and cause extra work.
> 
> Fixes: ec693d47010e8 ("net/mlx4_en: Add HW timestamping (TS) support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable.
