From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Tue, 19 Jul 2011 10:37:24 -0700 (PDT)
Message-ID: <20110719.103724.1461298517132188126.davem@davemloft.net>
References: <1311096229.2375.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab1GSRh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 13:37:28 -0400
In-Reply-To: <1311096229.2375.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jul 2011 19:23:49 +0200

> Maybe you can find the bug before me ?

I think when we add the route we cow the metrics almost immediately.
The daddr is, unfortunately, fully prefixed at that point.
