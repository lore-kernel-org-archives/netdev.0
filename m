From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about netif_rx
Date: Tue, 13 Aug 2013 08:29:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6> <20130811155640.GA10070@electric-eye.fr.zoreil.com> <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6> <20130813052036.GA11640@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1654509347-1376375365=:1997"
Cc: Julia Lawall <julia.lawall@lip6.fr>, grant.likely@linaro.org,
	rob.herring@calxeda.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130813052036.GA11640@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1654509347-1376375365=:1997
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Tue, 13 Aug 2013, Francois Romieu wrote:

> Julia Lawall <julia.lawall@lip6.fr> :
> > François Romieu <romieu@fr.zoreil.com> :
> [...]
> > > Can you send a netif_receive_skb replacement patch for it ?
> > 
> > Just to be sure, I just replace netif_rx by netif_receive_skb, nothing
> > else?
> 
> Yes. It should imho be fine with a comment incluing your analysis and a
> few words about the current state of checksum offloading support.

I wouldn't know what to say about the checksum part.  It is not supported 
so I should use netif_receive_skb?

thanks,
julia
--8323328-1654509347-1376375365=:1997--
