From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: free packet_rollover after
 synchronize_net
Date: Sun, 21 Jun 2015 09:31:26 -0700 (PDT)
Message-ID: <20150621.093126.1239806258533239115.davem@davemloft.net>
References: <1434473497-28551-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbbFUQTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:19:39 -0400
In-Reply-To: <1434473497-28551-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 16 Jun 2015 12:51:37 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Destruction of the po->rollover must be delayed until there are no
> more packets in flight that can access it. The field is destroyed in
> packet_release, before synchronize_net. Delay using rcu.
> 
> Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Willem.
