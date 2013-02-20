From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: remove an extra dst_release()
Date: Tue, 19 Feb 2013 22:24:11 -0500 (EST)
Message-ID: <20130219.222411.496018730437926446.davem@davemloft.net>
References: <1361312050.19353.169.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933950Ab3BTDYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 22:24:13 -0500
In-Reply-To: <1361312050.19353.169.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Feb 2013 14:14:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 68c331631143 (v4 GRE: Add TCP segmentation offload for GRE)
> introduced a bug in error path.
> 
> dst is attached to skb, so will be released when skb is freed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
