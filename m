From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 12:11:28 +0300
Message-ID: <201004151211.28315.nuclearcat@nuclearcat.com>
References: <1271318553.16881.2161.camel@edumazet-laptop> <1271321507.16881.2244.camel@edumazet-laptop> <20100415.020619.00349859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37290 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635Ab0DOJNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 05:13:33 -0400
In-Reply-To: <20100415.020619.00349859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Btw i have application using tun.

On Thursday 15 April 2010 12:06:19 David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 15 Apr 2010 10:51:47 +0200
> 
> > In any case, I think there is a fundamental problem with this sk
> > caching. Because one packet can travel in many stacked devices before
> > hitting the wire.
> >
> > (bonding, vlan, ethernet) for example.
> >
> > Socket cache is meaningfull for one level only...
> 
> We were talking the other day about that 'tun' change to orphan the
> SKB on TX, and I mentioned the possibility of just doing this in some
> generic location before we give the packet to the device ->xmit()
> method.
> 
> Such a scheme could help with this problem too.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
