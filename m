From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] ipv4: allow warming up the ARP cache with
 request type gratuitous ARP
Date: Tue, 19 Jan 2010 02:12:43 -0800 (PST)
Message-ID: <20100119.021243.14718033.davem@davemloft.net>
References: <201001190058.44495.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, chavey@google.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755436Ab0ASKMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:12:33 -0500
In-Reply-To: <201001190058.44495.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 19 Jan 2010 00:58:44 +0200

> If the per device ARP_ACCEPT option is enable, currently we only allow
> creating new ARP cache entries for response type gratuitous ARP.
> 
> Allowing gratuitous ARP to create new ARP entries (not only to update
> existing ones) is useful when we want to avoid unnecessary delays for
> the first packet of a stream.
> 
> This patch allows request type gratuitous ARP to create new ARP cache
> entries as well. This is useful when we want to populate the ARP cache
> entries for a large number of hosts on the same LAN.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, thanks.
