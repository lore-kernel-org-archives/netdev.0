From: David Miller <davem@davemloft.net>
Subject: Re: [PATC net-next] tcp: must block bh in __inet_twsk_hashdance()
Date: Wed, 04 May 2016 00:54:50 -0400 (EDT)
Message-ID: <20160504.005450.32648328658519474.davem@davemloft.net>
References: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbcEDEyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 00:54:52 -0400
In-Reply-To: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 May 2016 17:10:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __inet_twsk_hashdance() might be called from process context,
> better block BH before acquiring bind hash and established locks
> 
> Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
