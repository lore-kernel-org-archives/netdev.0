From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rtnetlink: rtnl_setlink() and
 rtnl_getlink() changes
Date: Thu, 22 Oct 2009 04:34:20 -0700 (PDT)
Message-ID: <20091022.043420.34866291.davem@davemloft.net>
References: <4ADF7633.9050208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754812AbZJVLd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 07:33:57 -0400
In-Reply-To: <4ADF7633.9050208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Oct 2009 22:59:31 +0200

> rtnl_getlink() & rtnl_setlink() run with RTNL held, we can use
> __dev_get_by_index() and __dev_get_by_name() variants and avoid
> dev_hold()/dev_put()
> 
> Adds to rtnl_getlink() the capability to find a device by its name,
> not only by its index.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks.
