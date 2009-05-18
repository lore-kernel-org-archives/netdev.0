From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: relay bridge multicast pkgs if !STP
Date: Sun, 17 May 2009 21:13:26 -0700 (PDT)
Message-ID: <20090517.211326.88138889.davem@davemloft.net>
References: <20090515091013.44b624d7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750775AbZEREN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:13:28 -0400
In-Reply-To: <20090515091013.44b624d7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 May 2009 09:10:13 -0700

> Currently the bridge catches all STP packets; even if STP is turned
> off.  This prevents other systems (which do have STP turned on)
> from being able to detect loops in the network.
> 
> With this patch, if STP is off, then any packet sent to the STP
> multicast group address is forwarded to all ports.
> 
> Based on earlier patch by Joakim Tjernlund with changes
> to go through forwarding (not local chain), and optimization
> that only last octet needs to be checked.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
