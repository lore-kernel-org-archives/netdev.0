From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: kill inet_putpeer race
Date: Mon, 11 Jul 2011 20:25:25 -0700 (PDT)
Message-ID: <20110711.202525.960905313394921992.davem@davemloft.net>
References: <1310388592.26049.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab1GLDZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:25:28 -0400
In-Reply-To: <1310388592.26049.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Jul 2011 14:49:52 +0200

> We currently can free inetpeer entries too early :
...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I assume this is only relevant to net-next-2.6, am I right?

Applied.
