From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Mon, 05 Oct 2015 06:33:57 -0700 (PDT)
Message-ID: <20151005.063357.333400071575282202.davem@davemloft.net>
References: <1443733536-992-1-git-send-email-avagin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@openvz.org, edumazet@google.com,
	aconole@bytheb.org
To: avagin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbJENST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:18:19 -0400
In-Reply-To: <1443733536-992-1-git-send-email-avagin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@gmail.com>
Date: Fri,  2 Oct 2015 00:05:36 +0300

> From: Andrey Vagin <avagin@openvz.org>
> 
> Now send with MSG_PEEK can return data from multiple SKBs.
> 
> Unfortunately we take into account the peek offset for each skb,
> that is wrong. We need to apply the peek offset only once.
> 
> In addition, the peek offset should be used only if MSG_PEEK is set.
> 
> Cc: "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
> Cc: Eric Dumazet <edumazet@google.com> (commit_signer:1/14=7%)
> Cc: Aaron Conole <aconole@bytheb.org>
> Fixes: 9f389e35674f ("af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag")
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied, thanks.
