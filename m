From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] display bound packet types
Date: Wed, 07 Mar 2007 18:56:40 -0800 (PST)
Message-ID: <20070307.185640.112291663.davem@davemloft.net>
References: <20070307164259.106c6c08@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751212AbXCHC4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 21:56:41 -0500
In-Reply-To: <20070307164259.106c6c08@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 7 Mar 2007 16:42:59 -0800

> While debugging I found it useful to see what packet types are in use.
> 
> This creates /proc/net/ptype with the format:
> 
> Type Device      Function
> ALL  eth0     [ffffffff880b01b6] :af_packet:packet_rcv_spkt+0x0
> 0800          [ffffffff802330f8] ip_rcv+0x0
> 0011          [ffffffff881021ef] :llc:llc_rcv+0x0
> 0004          [ffffffff881021ef] :llc:llc_rcv+0x0
> 0806          [ffffffff8043de7f] arp_rcv+0x0
> 86dd          [ffffffff880c1b57] :ipv6:ipv6_rcv+0x0
> 
> Is it worth the space?

I have no objections.

It would be nice to use kallsyms on that function address
though.
