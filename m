From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] arch/um/drivers: remove duplicate structure field
 initialization
Date: Wed, 21 Jul 2010 11:17:37 -0700 (PDT)
Message-ID: <20100721.111737.158419467.davem@davemloft.net>
References: <201007202225.o6KMPHA3021446@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk, shemminger@vyatta.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751170Ab0GUSRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 14:17:20 -0400
In-Reply-To: <201007202225.o6KMPHA3021446@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 20 Jul 2010 15:25:17 -0700

> From: Julia Lawall <julia@diku.dk>
> 
> There are two initializations of ndo_set_mac_address, one to a local
> function that is not used otherwise and one to a function that is defined
> elsewhere.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> 
> akpm:
> 
> - Use the standard eth_mac_addr() in uml_net_set_mac()
> 
> - Remove unneeded and racy local set_ether_mac()
> 
> - Remove duplicated (and incorrect)
>   uml_netdev_ops.ndo_set_mac_address initializer.
> 
> Fixes 8bb95b39a16ed55226810596f92216c53329d2fe ("uml: convert network
> device to netdevice ops").
> 
> [akpm@linux-foundation.org: rework as above]
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
