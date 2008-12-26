From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix (theoretical) overrun in message iteration
Date: Thu, 25 Dec 2008 17:20:38 -0800 (PST)
Message-ID: <20081225.172038.123581783.davem@davemloft.net>
References: <20081221134218.GA7959@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eugeneteo@kernel.sg, akpm@linux-foundation.org,
	viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752143AbYLZBUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 20:20:36 -0500
In-Reply-To: <20081221134218.GA7959@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Sun, 21 Dec 2008 14:42:18 +0100

> netlink: fix (theoretical) overrun in message iteration

I'll apply this but we should also consider getting rid
of unused interfaces such as nlmsg_for_each_msg().

