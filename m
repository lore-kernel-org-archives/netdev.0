From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next] net: tcp: add mib counters to track zero
 window transitions
Date: Wed, 26 Feb 2014 15:24:02 -0500 (EST)
Message-ID: <20140226.152402.1369443097743277303.davem@davemloft.net>
References: <1393335272-12914-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbaBZUYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:24:04 -0500
In-Reply-To: <1393335272-12914-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 25 Feb 2014 14:34:32 +0100

> Three counters are added:
> - one to track when we went from non-zero to zero window
> - one to track the reverse
> - one counter incremented when we want to announce zero window,
>   but can't because we would shrink current window.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks everyone.
