From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: fix a possible skb leak
Date: Tue, 25 Jun 2013 16:08:43 -0700 (PDT)
Message-ID: <20130625.160843.2198011969828835244.davem@davemloft.net>
References: <1372080360.3301.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dborkman@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3FYXIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:08:44 -0400
In-Reply-To: <1372080360.3301.61.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Jun 2013 06:26:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 68c331631143 ("v4 GRE: Add TCP segmentation offload for GRE")
> added a possible skb leak, because it frees only the head of segment
> list, in case a skb_linearize() call fails.
> 
> This patch adds a kfree_skb_list() helper to fix the bug.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
