From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist
 termination
Date: Sat, 01 Nov 2008 21:22:31 -0700 (PDT)
Message-ID: <20081101.212231.24828761.davem@davemloft.net>
References: <4909E0A4.7060009@acm.org>
	<490B183E.3010707@cosmosbay.com>
	<490B1C76.6090008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, minyard@acm.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org, cl@linux-foundation.org,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru, christian@myri.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750902AbYKBEW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:22:57 -0400
In-Reply-To: <490B1C76.6090008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 31 Oct 2008 17:55:50 +0300

> > Well, looking at current implementation, I found that udp_v4_mcast_next()
> > doesnt take into account the 'struct net *net', so we have a bug here...
> > 
> > udp_v6_mcast_next() is buggy too (or at least its caller is)
> > 
> > David, please find a patch against net-2.6
> > 
> > Thanks
> > 
> > [PATCH] udp: multicast packets need to check namespace
> > 
> > Current UDP multicast delivery is not namespace aware.
> > 
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks everyone.
