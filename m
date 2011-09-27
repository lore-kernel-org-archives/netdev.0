From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 02:20:25 -0400 (EDT)
Message-ID: <20110927.022025.1306291417181821045.davem@davemloft.net>
References: <1316757739.2560.12.camel@edumazet-laptop>
	<20110927.005905.1166544891922183065.davem@davemloft.net>
	<1317103249.2796.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab1I0GUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 02:20:41 -0400
In-Reply-To: <1317103249.2796.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Sep 2011 08:00:49 +0200

> struct tcp_skb_cb contains a "flags" field containing either tcp flags
> or IP dsfield depending on context (input or output path)
> 
> Introduce ip_dsfield to make the difference clear and ease maintenance.
> If later we want to save space, we can union flags/ip_dsfield
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

> If there is no objection, I plan to rename "flags" to "tcp_flags" in a
> following patch.

No objections.
