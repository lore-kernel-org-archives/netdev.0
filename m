From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] fec: Remove fec_enet_select_queue()
Date: Fri, 26 Sep 2014 15:22:14 -0400 (EDT)
Message-ID: <20140926.152214.2057397298920833937.davem@davemloft.net>
References: <1411419329-11957-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbaIZTWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:22:16 -0400
In-Reply-To: <1411419329-11957-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon, 22 Sep 2014 17:55:29 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Sparse complains about fec_enet_select_queue() not being static.
> 
> Feedback from David Miller [1] was to remove this function instead of making it
> static:
> 
> "Please just delete this function.
> 
> It's overriding code which does exactly the same thing.
> 
> Actually, more precisely, this code is duplicating code in a way that
> bypasses many core facilitites of the networking.  For example, this
> override means that socket based flow steering, XPS, etc. are all
> not happening on these devices.
> 
> Without ->ndo_select_queue(), the flow dissector does __netdev_pick_tx
> which is exactly what you want to happen."
> 
> [1] http://www.spinics.net/lists/netdev/msg297653.html
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Looks a lot better, applied, thanks!
