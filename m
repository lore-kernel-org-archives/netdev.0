From: Thomas Graf <tgraf@suug.ch>
Subject: Re: ProxyARP and IPSec
Date: Thu, 24 Aug 2006 12:50:37 +0200
Message-ID: <20060824105037.GL3470@postel.suug.ch>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hpa@zytor.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:1964 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751089AbWHXKuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 06:50:17 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060823.151424.78711856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-08-23 15:14
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 23 Aug 2006 21:14:25 +0200
> 
> > * H. Peter Anvin <hpa@zytor.com> 2006-08-22 17:31
> > > Specifically, Linux will not ProxyARP for an address unless it has a 
> > > route for it, *and* that route either has a DNAT marking or points to a 
> > > different interface than the input interface:
> > 
> > I can think of a very ugly way: Use netfilter to match on the
> > arp packet prerouting, set nfmark to some value, create a routing
> > rule matching the fwmark again, have it look up a separate table
> > with a dummy route pointing to a dummy device. Make sure to have
> > a proxy neighbour entry as using the device proxy_arp sysctl would
> > fail again.
> 
> This shows we have a usability problem if that's the only way
> to do this :-)

What about adding blackhole device to be used for such routes.
I believe it would be good architecture to always use devices
to state directions packets are being received from and sent to.
