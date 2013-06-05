From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netpoll: fix position of network header
Date: Tue, 04 Jun 2013 17:37:25 -0700 (PDT)
Message-ID: <20130604.173725.1985662799102367999.davem@davemloft.net>
References: <1370313096-4527-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, dborkmann@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab3FEAh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:37:29 -0400
In-Reply-To: <1370313096-4527-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  4 Jun 2013 10:31:36 +0800

> Similar to the problem in pktgen, netpoll uses skb_tail_offset()
> too, as the code is copied from pktgen.
> 
> Also use return values of skb_put() directly, this will simiplify
> the code.
> 
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Daniel Borkmann <dborkmann@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
