From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netpoll: call ->ndo_select_queue() in tx path
Date: Wed, 19 Sep 2012 17:21:08 -0400 (EDT)
Message-ID: <20120919.172108.1539457128236567338.davem@davemloft.net>
References: <1347948991-20860-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.munaut@whatever-company.com,
	edumazet@google.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab2ISVVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 17:21:10 -0400
In-Reply-To: <1347948991-20860-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 18 Sep 2012 14:16:31 +0800

> In netpoll tx path, we miss the chance of calling ->ndo_select_queue(),
> thus could cause problems when bonding is involved.
> 
> This patch makes dev_pick_tx() extern (and rename it to netdev_pick_tx())
> to let netpoll call it in netpoll_send_skb_on_dev().
> 
> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>

Applied, thanks.
