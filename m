From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix can_checksum_protocol() arguments swap
Date: Wed, 19 Jan 2011 14:14:36 -0800 (PST)
Message-ID: <20110119.141436.55850267.davem@davemloft.net>
References: <1295434296.3273.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, jmdebruin@xmsnet.nl
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754142Ab1ASWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 17:14:02 -0500
In-Reply-To: <1295434296.3273.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Jan 2011 11:51:36 +0100

> commit 0363466866d901fbc (net offloading: Convert checksums to use
> centrally computed features.) mistakenly swapped can_checksum_protocol()
> arguments.
> 
> This broke IPv6 on bnx2 for instance, on NIC without TCPv6 checksum
> offloads.
> 
> Reported-by: Hans de Bruin <jmdebruin@xmsnet.nl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jesse Gross <jesse@nicira.com>

Applied, thanks!
