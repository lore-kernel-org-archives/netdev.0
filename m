From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] net: show bound packet types
Date: Mon, 12 Mar 2007 14:35:58 -0700 (PDT)
Message-ID: <20070312.143558.45180069.davem@davemloft.net>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.760118389@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932386AbXCLVgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:36:01 -0400
In-Reply-To: <20070312210907.760118389@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 14:08:20 -0700

> Show what protocols are bound to what packet types in /proc/net/ptype
> Uses kallsyms to decode function pointers if possible.
> Example:
> 	Type Device      Function
> 	ALL  eth1     packet_rcv_spkt+0x0
> 	0800          ip_rcv+0x0
> 	0806          arp_rcv+0x0
> 	86dd          :ipv6:ipv6_rcv+0x0
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks for adding the kallsyms bits.
