From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix regression in urgent data handling
Date: Tue, 18 Sep 2012 16:26:51 -0400 (EDT)
Message-ID: <20120918.162651.1368150594651951061.davem@davemloft.net>
References: <1347922299.26523.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, springl-k@lar.bfw.de,
	alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab2IRU0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:26:53 -0400
In-Reply-To: <1347922299.26523.198.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Sep 2012 00:51:39 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Stephan Springl found that commit 1402d366019fed "tcp: introduce
> tcp_try_coalesce" introduced a regression for rlogin
> 
> It turns out problem comes from TCP urgent data handling and
> a change in behavior in input path.
> 
> rlogin sends two one-byte packets with URG ptr set, and when next data
> frame is coalesced, we lack sk_data_ready() calls to wakeup consumer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Stephan Springl <springl-k@lar.bfw.de>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks Eric.
