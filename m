From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: minor: tcp: use tcp_skb_mss helper
 in tcp_tso_segment
Date: Fri, 07 Jun 2013 14:39:47 -0700 (PDT)
Message-ID: <20130607.143947.1324118528707891830.davem@davemloft.net>
References: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab3FGVjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 17:39:48 -0400
In-Reply-To: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  7 Jun 2013 17:11:45 +0200

> We have the minimal inline helper tcp_skb_mss to access
> skb_shinfo(skb)->gso_size, so also use it here to get mss.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
