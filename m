From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: sock_tx_timestamp() fix
Date: Wed, 06 Aug 2014 12:38:32 -0700 (PDT)
Message-ID: <20140806.123832.908328158138196740.davem@davemloft.net>
References: <1407204710-21778-6-git-send-email-willemb@google.com>
	<1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1407318569.11943.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	richardcochran@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbaHFTid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 15:38:33 -0400
In-Reply-To: <1407318569.11943.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Aug 2014 11:49:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> sock_tx_timestamp() should not ignore initial *tx_flags value, as TCP
> stack can store SKBTX_SHARED_FRAG in it.
> 
> Also first argument (struct sock *) can be const.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 4ed2d765dfac ("net-timestamp: TCP timestamping")

Applied, thanks Eric.
