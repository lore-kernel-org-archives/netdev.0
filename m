From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Tue, 29 Jun 2010 01:30:26 +0200
Message-ID: <OFA9AE9CDE.69224382-ONC1257750.007F44EA-C1257750.0081210A@transmode.se>
References: <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>	<1277754121.4235.673.camel@edumazet-laptop>
	<OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se> <20100628.145744.39186500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50518 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab0F1Xa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 19:30:57 -0400
In-Reply-To: <20100628.145744.39186500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 2010/06/28 23:57:44:
>
> From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Date: Mon, 28 Jun 2010 23:09:02 +0200
>
> > To me it "ifconfig eth0 down" means not only to stop using the I/F
> > but also any IP address associated with the I/F.
>
> IP addresses are associated with the host, not a particular interface.
>
> Therefore the state of the interface should not influence the behavior
> of the IP address.
>
> If you want the IP address to stop being responded to, delete the IP
> address.

This is an strict interpretation of the weak host model and does not
answer my questions. Mind to elaborate why such a strict view and
what is gained by answering on an IP address which has been "downed"?
What types of apps use this property?

 Jocke

