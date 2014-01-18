From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: tcp: fix flowlabel value in ACK
 messages send from TIME_WAIT
Date: Fri, 17 Jan 2014 17:57:24 -0800 (PST)
Message-ID: <20140117.175724.1608375616732183823.davem@davemloft.net>
References: <1389889282-2562-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaARB5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:57:25 -0500
In-Reply-To: <1389889282-2562-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Thu, 16 Jan 2014 17:21:22 +0100

> This patch is following the commit b903d324bee262 (ipv6: tcp: fix TCLASS
> value in ACK messages sent from TIME_WAIT).
> 
> For the same reason than tclass, we have to store the flow label in the
> inet_timewait_sock to provide consistency of flow label on the last ACK.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied, thank you.
