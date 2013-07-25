From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] net: add sk_stream_is_writeable()
 helper
Date: Wed, 24 Jul 2013 17:55:05 -0700 (PDT)
Message-ID: <20130724.175505.163226229619748359.davem@davemloft.net>
References: <1374549991.4990.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com, ycheng@google.com,
	ncardwell@google.com, mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab3GYAzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:55:06 -0400
In-Reply-To: <1374549991.4990.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Jul 2013 20:26:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Several call sites use the hardcoded following condition :
> 
> sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)
> 
> Lets use a helper because TCP_NOTSENT_LOWAT support will change this
> condition for TCP sockets.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
