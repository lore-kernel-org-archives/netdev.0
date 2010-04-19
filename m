From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 13:21:58 -0700 (PDT)
Message-ID: <20100419.132158.143863746.davem@davemloft.net>
References: <1271683627.3845.44.camel@edumazet-laptop>
	<1271686957.3845.49.camel@edumazet-laptop>
	<1271689653.3845.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751178Ab0DSUVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 16:21:55 -0400
In-Reply-To: <1271689653.3845.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Apr 2010 17:07:33 +0200

> [PATCH net-next-2.6] rps: shortcut net_rps_action()

Applied, thanks Eric.

It is getting increasingly complicated to follow who enables and
disabled local cpu irqs in these code paths.  We could combat
this by adding something like "_irq_enable()" to the function
names.
