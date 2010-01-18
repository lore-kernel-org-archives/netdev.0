From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: support for request type gratuitous ARP
Date: Sun, 17 Jan 2010 19:05:40 -0800 (PST)
Message-ID: <20100117.190540.22362723.davem@davemloft.net>
References: <Pine.LNX.4.58.1001171310420.2769@u.domain.uli>
	<201001172055.52953.opurdila@ixiacom.com>
	<Pine.LNX.4.58.1001172213550.10728@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org, chavey@google.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753345Ab0ARDFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:05:30 -0500
In-Reply-To: <Pine.LNX.4.58.1001172213550.10728@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 17 Jan 2010 22:43:54 +0200 (EET)

> 	Looks correct to me. You will save some CPU cycles
> if the 'arp->ar_op == htons(ARPOP_REQUEST)' check is not added.
> May be you also need to change arp_accept in 
> Documentation/networking/ip-sysctl.txt to show that we do not 
> differentiate Gratuitous ARP requests from replies.

Octavian, please make the documentation fix for 'arp_accept'
and resubmit your patch.

It otherwise looks fine to me now.

Thanks.
