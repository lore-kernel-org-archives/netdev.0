From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] Minor clenup: remove two unused definitions in
 net/ip6_route.h
Date: Thu, 07 Feb 2008 18:11:00 -0800 (PST)
Message-ID: <20080207.181100.226258547.davem@davemloft.net>
References: <eb3ff54b0802070758j21299257m19e04fffdedd914@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbYBHCK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 21:10:29 -0500
In-Reply-To: <eb3ff54b0802070758j21299257m19e04fffdedd914@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Thu, 7 Feb 2008 17:58:07 +0200

> Remove IP6_RT_PRIO_FW and IP6_RT_FLOW_MASK definitions in
> include/net/ip6_route.h, as they are not used in the kernel.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.

If you grep for "fc_metric" in the tree you'll see some
explicit uses of the magic constant "1024" which probably
should be replaced with IP6_RT_PRIO_USER.  If you could
verify that and cook up a patch if correct, I'd appreciate
it.

Thanks.
