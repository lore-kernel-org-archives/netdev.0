From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Mon, 28 Jun 2010 14:57:44 -0700 (PDT)
Message-ID: <20100628.145744.39186500.davem@davemloft.net>
References: <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
	<1277754121.4235.673.camel@edumazet-laptop>
	<OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753488Ab0F1V5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 17:57:32 -0400
In-Reply-To: <OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Mon, 28 Jun 2010 23:09:02 +0200

> To me it "ifconfig eth0 down" means not only to stop using the I/F
> but also any IP address associated with the I/F.

IP addresses are associated with the host, not a particular interface.

Therefore the state of the interface should not influence the behavior
of the IP address.

If you want the IP address to stop being responded to, delete the IP
address.
