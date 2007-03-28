From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6.22] [IPV6] FIB6RULE: Find source address during
 looking up route.
Date: Wed, 28 Mar 2007 12:49:40 +0900 (JST)
Message-ID: <20070328.124940.55792158.yoshfuji@linux-ipv6.org>
References: <20070327.224537.09436398.yoshfuji@linux-ipv6.org>
	<20070327142519.GN521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, takamiya@po.ntts.co.jp,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35271 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbXC1Dsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 23:48:55 -0400
In-Reply-To: <20070327142519.GN521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070327142519.GN521@postel.suug.ch> (at Tue, 27 Mar 2007 16:25:19 +0200), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2007-03-27 22:45
> > When looking up route for destination with rules with
> > source address restrictions, we may need to find a source
> > address for the traffic if not given.
> 
> Out of curiosity, what sort of rules would have this flag set?
> The majority of lookups don't provide a valid source address.
> This new address search could become very expensive, because
> none of the results are cached.

This flags is used for Mobile IPv6.

Well, for non-connected sockets on hosts, yes,
the process might not be light-weight.
But, on routers, or once the socket is connected,
source address should be always set.

> This chunk won't apply to latest net-2.6.22, I've added two more
> flags yesterday.

Oops,... I'll send rebased version...

--yoshfuji
