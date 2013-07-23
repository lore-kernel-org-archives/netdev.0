From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/4] tcp: consolidate SYNACK RTT sampling
Date: Mon, 22 Jul 2013 18:02:55 -0700 (PDT)
Message-ID: <20130722.180255.685921996264320731.davem@davemloft.net>
References: <1374535248-27418-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab3GWBC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:02:59 -0400
In-Reply-To: <1374535248-27418-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 22 Jul 2013 16:20:45 -0700

> This patch series improve RTT sampling in three ways:
> 1. Sample RTT during fast recovery and reordering events.
> 2. Favor ack-based RTT to timestamps because of broken TS ECR fields
> 3. Consolidate the RTT measurement logic.
> 
> The first patch consolidates SYNACK and other RTT measurement to use a
> central function tcp_ack_update_rtt(). A (small) bonus is now SYNACK
> RTT measurement happens after PAWS check, potentially reducing the
> impact of RTO seeding on bad TCP timestamps values.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

I like this series a lot, applied, thanks!

Next time please submit a seperate "[PATCH 0/4] xxx" posting.

If it has non-trivial content, I use the "0" posting as the
commit message of a merge commit when I apply your series.

What I did here was take the text:

====================
This patch series improve RTT sampling in three ways:
1. Sample RTT during fast recovery and reordering events.
2. Favor ack-based RTT to timestamps because of broken TS ECR fields
3. Consolidate the RTT measurement logic.
====================

and place it into that merge commit, removing it from the patch #1
commit message.

Thanks.
