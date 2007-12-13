From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] ip_gre: Rebinding of GRE tunnels to other
 interfaces
Date: Thu, 13 Dec 2007 09:47:18 -0800 (PST)
Message-ID: <20071213.094718.97123365.davem@davemloft.net>
References: <20071213133748.862042979@redhat.com>
	<20071213133922.223489455@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, mmaslano@redhat.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34487
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756893AbXLMRrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:47:18 -0500
In-Reply-To: <20071213133922.223489455@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mschmidt@redhat.com
Date: Thu, 13 Dec 2007 14:37:49 +0100

> This is similar to the change already done for IPIP tunnels.
> 
> Once created, a GRE tunnel can't be bound to another device.
> To reproduce:
> 
> # create a tunnel:
> ip tunnel add tunneltest0 mode gre remote 10.0.0.1 dev eth0
> # try to change the bounding device from eth0 to eth1:
> ip tunnel change tunneltest0 dev eth1
> # show the result:
> ip tunnel show tunneltest0
> 
> tunneltest0: gre/ip  remote 10.0.0.1  local any  dev eth0  ttl inherit
> 
> Notice the bound device has not changed from eth0 to eth1.
> 
> This patch fixes it. When changing the binding, it also recalculates the
> MTU according to the new bound device's MTU.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied to net-2.6.25, thanks.
