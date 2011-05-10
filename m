From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 09 May 2011 20:49:59 -0700 (PDT)
Message-ID: <20110509.204959.71127408.davem@davemloft.net>
References: <1304995413.3050.19.camel@edumazet-laptop>
	<20110509201705.409f6d39@nehalam>
	<1304999127.3050.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43516
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455Ab1EJDub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:50:31 -0400
In-Reply-To: <1304999127.3050.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 May 2011 05:45:27 +0200

> We only need to maintain a global variable to hold min_dump_alloc
> 
> [ and only increase this variable when necessary, not bother to decrease
> it when removing a driver ]

Agreed, this is probably the best approach.
