From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: refine TSO autosizing
Date: Sat, 06 Dec 2014 08:58:46 -0800
Message-ID: <1417885126.15618.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417832560.15618.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:41128 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaLFQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 11:58:56 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so846995igi.6
        for <netdev@vger.kernel.org>; Sat, 06 Dec 2014 08:58:55 -0800 (PST)
In-Reply-To: <1417832560.15618.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 18:22 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

...

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
> v2: added tcp_tso_autosize() helper and removed tp->xmit_size_goal_segs

Please do not apply this patch. I'll send a v3.

We still need to cook skb with a multiple of mss bytes.
