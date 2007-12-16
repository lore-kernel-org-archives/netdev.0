From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 13:37:17 -0800 (PST)
Message-ID: <20071216.133717.202852113.davem@davemloft.net>
References: <20071211145243.66e1f66a@freepuppy.rosehill>
	<20071211145921.11094ab8.akpm@linux-foundation.org>
	<20071211154835.75ace6bc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	jeff@garzik.org, herbert@gondor.apana.org.au, rjw@sisk.pl
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758587AbXLPVh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:37:27 -0500
In-Reply-To: <20071211154835.75ace6bc@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 11 Dec 2007 15:48:35 -0800

> Subject: Re: [PATCH] bridge: assign random address

"bridge" should all-caps and in brackets, "assign random address"
should be capitalized like a proper english sentence with a period at
the end.

These are changelog messages for a mature and professional software
project, not random comments amongst teenagers on an IRC channel.

> Assigning a valid random address to bridge device solves problems
> when bridge device is brought up before adding real device to bridge.
> When the first real device is added to the bridge, it's address
> will overide the bridges random address.
> 
> Note: any device added to a bridge must already have a valid
> ethernet address.
>  br_add_if -> br_fdb_insert -> fdb_insert -> is_valid_ether_addr
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6, thanks.
