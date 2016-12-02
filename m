From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] tcp: allow to turn tcp timestamp
 randomization off
Date: Fri, 02 Dec 2016 12:50:18 -0500 (EST)
Message-ID: <20161202.125018.259538176046774417.davem@davemloft.net>
References: <1480588327-2902-1-git-send-email-fw@strlen.de>
        <1480588327-2902-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbcLBRuU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:50:20 -0500
In-Reply-To: <1480588327-2902-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  1 Dec 2016 11:32:07 +0100

> Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
> flows, we can deduct the relative qdisc delays (think of fq pacing).
> This should work even if we have one flow per remote peer."
> 
> Having random per flow (or host) offsets doesn't allow that anymore so add
> a way to turn this off.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied.
