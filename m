From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/3] bonding,ipv4,ipv6,vlan: Use notifiers
 to trigger advertisements on failover
Date: Sun, 17 Apr 2011 23:34:30 -0700 (PDT)
Message-ID: <20110417.233430.232729817.davem@davemloft.net>
References: <1302910861.2845.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
	netdev@vger.kernel.org, Ian.Campbell@citrix.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57762
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069Ab1DRGfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 02:35:04 -0400
In-Reply-To: <1302910861.2845.36.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 16 Apr 2011 00:41:01 +0100

> It is undesirable for the bonding driver to be poking into higher
> level protocols, and notifiers provide a way to avoid that.
> 
> Ian added NETDEV_NOTIFY_PEERS to trigger gratuitous ARP on VM migration.
> We should extend that to unsolicited NAs and propagate it through VLANs,
> then treat bonding failover in the same way.

I'm going to apply these patches since they clean up so much.

If the concerns brought up by Jay or Brian need to be addressed,
we can either add fixes or in the worst case revert.

Thanks!
