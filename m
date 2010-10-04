From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce DST_NOCACHE flag
Date: Sun, 03 Oct 2010 22:18:46 -0700 (PDT)
Message-ID: <20101003.221846.245388012.davem@davemloft.net>
References: <1285868687.2615.900.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751356Ab0JDFS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:18:26 -0400
In-Reply-To: <1285868687.2615.900.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 19:44:47 +0200

 ...
> Introduce a new dst flag, DST_NOCACHE, that is set when dst was not
> inserted in route cache.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Cute, and applied, but it shows that we're RCU'd so much of the
surrounding infrastructure that the neighbour cache is now pretty
high on the list of things to RCU.
