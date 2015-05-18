From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/ipv6: fix flow label setting in TIME_WAIT state
Date: Sun, 17 May 2015 23:42:48 -0400 (EDT)
Message-ID: <20150517.234248.1576140644953139081.davem@davemloft.net>
References: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431728699-7767-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbERDmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:42:49 -0400
In-Reply-To: <1431728699-7767-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Sat, 16 May 2015 00:24:59 +0200

> commit 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages
> send from TIME_WAIT") added the flow label in the last TCP packets.
> Unfortunately, it was not casted properly.
> 
> This patch replace the buggy shift with be32_to_cpu/cpu_to_be32.
> 
> Fixes: 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied and queued up for -stable, thanks.
