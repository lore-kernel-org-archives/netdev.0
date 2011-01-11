From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] NET: IPV4: ARP: allow to invalidate specific ARP
 entries
Date: Mon, 10 Jan 2011 16:11:12 -0800 (PST)
Message-ID: <20110110.161112.62346640.davem@davemloft.net>
References: <1294404478.7674.0.camel@maxim-laptop>
	<1294405062.3306.11.camel@edumazet-laptop>
	<1294531032.25396.11.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: maximlevitsky@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab1AKAKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:10:41 -0500
In-Reply-To: <1294531032.25396.11.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sun, 09 Jan 2011 01:57:12 +0200

>     NET: IPV4: ARP: allow to invalidate specific ARP entries
>     
>     IPv4 over firewire needs to be able to remove ARP entries
>     from the ARP cache that belong to nodes that are removed, because
>     IPv4 over firewire uses ARP packets for private information
>     about nodes.
>     
>     This information becomes invalid as soon as node drops
>     off the bus and when it reconnects, its only possible
>     to start takling to is after it responded to an ARP packet.
>     But ARP cache prevents such packets from being sent.
>     
>     Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

Applied, thanks.
